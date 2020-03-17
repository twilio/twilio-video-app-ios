//
//  Copyright (C) 2020 Twilio, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Alamofire

protocol APIConfiguring: AnyObject {
    var config: APIConfig! { get set }
    var errorResponseDecoder: APIErrorResponseDecoder! { get set }
}

protocol APIRequesting: AnyObject {
    func request<Request: APIRequest>(
        _ request: Request,
        completion: @escaping (Result<Request.Response, APIError>) -> Void
    )
}

class API: APIConfiguring, APIRequesting {
    static var shared: APIConfiguring & APIRequesting = API(
        session: Session(),
        urlFactory: APIURLFactoryImpl(),
        jsonEncoder: JSONEncoder(),
        jsonDecoder: JSONDecoder()
    )
    var config: APIConfig!
    var errorResponseDecoder: APIErrorResponseDecoder!
    private let session: Session
    private let urlFactory: APIURLFactory
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    private var headers: HTTPHeaders? {
        guard let idToken = config.idToken else { return nil }
        
        return [.authorization(idToken)]
    }

    init(session: Session, urlFactory: APIURLFactory, jsonEncoder: JSONEncoder, jsonDecoder: JSONDecoder) {
        self.session = session
        self.urlFactory = urlFactory
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
    }
    
    func request<Request: APIRequest>(
        _ request: Request,
        completion: @escaping (Result<Request.Response, APIError>) -> Void
    ) {
        session.request(
            urlFactory.makeURL(host: config.host, path: request.path),
            method: HTTPMethod(apiHTTPMethod: request.method),
            parameters: request.parameters,
            encoder: makeParameterEncoder(encoding: request.encoding),
            headers: headers
        ).validate().responseDecodableOrString(of: request.responseType, decoder: jsonDecoder) { [weak self] response in
            guard let self = self else { return }
            
            switch response.result {
            case let .success(response):
                completion(.success(response))
            case let .failure(error):
                guard !error.isNotConnectedToInternetError else { completion(.failure(.notConnectedToInternet)); return }
                guard let data = response.data else { completion(.failure(.decodeError)); return }

                completion(.failure(self.errorResponseDecoder.decode(data: data)))
            }
        }
    }
    
    private func makeParameterEncoder(encoding: APIEncoding) -> ParameterEncoder {
        switch encoding {
        case .jsonBody: return JSONParameterEncoder(encoder: jsonEncoder)
        case .queryStringURL: return URLEncodedFormParameterEncoder()
        }
    }
}

private extension AFError {
    var isNotConnectedToInternetError: Bool {
        guard let underlyingError = underlyingError, isSessionTaskError else { return false }

        let error = underlyingError as NSError
        return error.domain == NSURLErrorDomain && error.code == NSURLErrorNotConnectedToInternet
    }
}

private extension HTTPMethod {
    init(apiHTTPMethod: APIHTTPMethod) {
        switch apiHTTPMethod {
        case .post: self = .post
        case .get: self = .get
        }
    }
}

extension DataRequest {
    @discardableResult func responseDecodableOrString<T: Decodable>(
        of type: T.Type = T.self,
        decoder: DataDecoder,
        completionHandler: @escaping (AFDataResponse<T>) -> Void
    ) -> Self {
        if type is String.Type {
            return responseString { completionHandler( $0.map { $0 as! T }) }
        } else {
            return responseDecodable(of: type, decoder: decoder, completionHandler: completionHandler)
        }
    }
}
