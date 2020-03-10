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

@testable import VideoApp

class MockAPI: APIConfiguring, APIRequesting {
    var invokedConfigSetter = false
    var invokedConfigSetterCount = 0
    var invokedConfig: APIConfig?
    var invokedConfigList = [APIConfig?]()
    var invokedConfigGetter = false
    var invokedConfigGetterCount = 0
    var stubbedConfig: APIConfig!
    var config: APIConfig! {
        set {
            invokedConfigSetter = true
            invokedConfigSetterCount += 1
            invokedConfig = newValue
            invokedConfigList.append(newValue)
        }
        get {
            invokedConfigGetter = true
            invokedConfigGetterCount += 1
            return stubbedConfig
        }
    }
    var invokedErrorResponseDecoderSetter = false
    var invokedErrorResponseDecoderSetterCount = 0
    var invokedErrorResponseDecoder: APIErrorResponseDecoder?
    var invokedErrorResponseDecoderList = [APIErrorResponseDecoder?]()
    var invokedErrorResponseDecoderGetter = false
    var invokedErrorResponseDecoderGetterCount = 0
    var stubbedErrorResponseDecoder: APIErrorResponseDecoder!
    var errorResponseDecoder: APIErrorResponseDecoder! {
        set {
            invokedErrorResponseDecoderSetter = true
            invokedErrorResponseDecoderSetterCount += 1
            invokedErrorResponseDecoder = newValue
            invokedErrorResponseDecoderList.append(newValue)
        }
        get {
            invokedErrorResponseDecoderGetter = true
            invokedErrorResponseDecoderGetterCount += 1
            return stubbedErrorResponseDecoder
        }
    }
    var invokedRequest = false
    var invokedRequestCount = 0
    var invokedRequestParameters: (request: Any, Void)?
    var invokedRequestParametersList = [(request: Any, Void)]()
    var stubbedRequestCompletionResult: Result<Any, APIError>?
    func request<Request: APIRequest>(
    _ request: Request,
    completion: @escaping (Result<Request.Response, APIError>) -> Void
    ) {
        invokedRequest = true
        invokedRequestCount += 1
        invokedRequestParameters = (request, ())
        invokedRequestParametersList.append((request, ()))
        if let result = stubbedRequestCompletionResult {
            switch result {
            case let .success(response): completion(.success(response as! Request.Response))
            case let .failure(error): completion(.failure(error))
            }
        }
    }
}
