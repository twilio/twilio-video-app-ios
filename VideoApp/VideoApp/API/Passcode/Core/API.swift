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
    var config: APIConfig!
    private let session = Session()
    private let jsonDecoder = JSONDecoder()
    private let jsonParameterEncoder: JSONParameterEncoder

    init() {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        jsonParameterEncoder = JSONParameterEncoder(encoder: jsonEncoder)
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    func request<Request: APIRequest>(
        _ request: Request,
        completion: @escaping (Result<Request.Response, APIError>) -> Void
    ) {
        let url = "https://\(config.host)/\(request.path)"
        
        session.request(
            url,
            method: HTTPMethod(apiHTTPMethod: request.method),
            parameters: request.parameters,
            encoder: jsonParameterEncoder
        ).validate().response { [weak self] response in
            guard let self = self else { return }
            
            switch response.result {
            case let .success(data):
                guard let data = data else { completion(.failure(.decodeError)); return }
                
                do {
                    completion(.success(try self.jsonDecoder.decode(request.responseType, from: data)))
                } catch {
                    completion(.failure(.decodeError))
                }
            case let .failure(error):
                guard !error.isNotConnectedToInternetError else { completion(.failure(.notConnectedToInternet)); return }
                guard let data = response.data else { completion(.failure(.decodeError)); return }

                do {
                    let errorResponse = try self.jsonDecoder.decode(APIErrorResponse.self, from: data)
                    completion(.failure(APIError(message: errorResponse.error.message)))
                } catch {
                    completion(.failure(.decodeError))
                }
            }
        }
    }
}

private extension APIError {
    init(message: APIErrorResponse.Error.Message) {
        switch message {
        case .passcodeExpired: self = .passcodeExpired
        case .passcodeIncorrect: self = .passcodeIncorrect
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
        }
    }
}
