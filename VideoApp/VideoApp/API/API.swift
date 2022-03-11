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
        jsonDecoder: JSONDecoder()
    )
    var config: APIConfig!
    private let session: Session
    private let urlFactory: APIURLFactory
    private let jsonDecoder: JSONDecoder
    private let parameterEncoder: JSONParameterEncoder
    private var headers: HTTPHeaders? {
        guard let idToken = config.idToken else { return nil }
        
        return [.authorization(idToken)]
    }

    init(session: Session, urlFactory: APIURLFactory, jsonDecoder: JSONDecoder) {
        self.session = session
        self.urlFactory = urlFactory
        self.jsonDecoder = jsonDecoder
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        parameterEncoder = JSONParameterEncoder(encoder: jsonEncoder)
    }
    
    func request<Request: APIRequest>(
        _ request: Request,
        completion: @escaping (Result<Request.Response, APIError>) -> Void
    ) {
        session.request(
            urlFactory.makeURL(host: config.host, path: request.path),
            method: .post, // Twilio Functions does not care about method
            parameters: request.parameters,
            encoder: parameterEncoder,
            headers: headers
        )
            .validate()
            .responseDecodable(of: request.responseType, decoder: jsonDecoder) { [weak self] response in
                guard let self = self else { return }
                
                switch response.result {
                case let .success(response):
                    completion(.success(response))
                case let .failure(error):
                    guard let data = response.data else {
                        completion(.failure(.message(message: error.localizedDescription)))
                        return
                    }
                    
                    do {
                        let errorResponse = try self.jsonDecoder.decode(APIErrorResponse.self, from: data)
                        completion(.failure(.message(message: errorResponse.error.explanation)))
                    } catch {
                        completion(.failure(.message(message: error.localizedDescription)))
                    }
                }
            }
    }
}
