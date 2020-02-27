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

protocol PasscodeAPIWriting: AnyObject {
    func fetchTwilioAccessToken(
        passcode: String,
        userIdentity: String,
        roomName: String,
        completion: @escaping (Result<String, PasscodeAPIError>) -> Void
    )
}

enum PasscodeAPIError: Error {
    case expiredPasscode
    case other
    case unauthorized
}

class PasscodeAPI: PasscodeAPIWriting {
    struct FetchTwilioAccessTokenParameters: Encodable {
        let passcode: String
        let userIdentity: String
        let roomName: String
    }

    struct FetchTwilioAccessTokenResponse: Decodable {
        let token: String
    }

    struct ErrorResponse: Decodable {
        enum Error: String, Decodable {
            case expired
            case unauthorized
        }
        
        let error: Error
    }

    private let session = Session()

    func fetchTwilioAccessToken(
        passcode: String,
        userIdentity: String,
        roomName: String,
        completion: @escaping (Result<String, PasscodeAPIError>) -> Void
    ) {
        let passcodeComponents = PasscodeComponents(string: passcode)
        let url = "https://video-app-\(passcodeComponents.appID)-dev.twil.io/token"
        let parameters = FetchTwilioAccessTokenParameters(
            passcode: passcodeComponents.apiPasscode,
            userIdentity: userIdentity,
            roomName: roomName
        )
        let encoder = JSONParameterEncoder(encoder: SnakeCaseJSONEncoder())
        
        session.request(url, method: .post, parameters: parameters, encoder: encoder).validate().response { response in
            let jsonDecoder = SnakeCaseJSONDecoder()

            switch response.result {
            case let .success(data):
                let fetchTwilioAccessTokenResponse = try! jsonDecoder.decode(FetchTwilioAccessTokenResponse.self, from: data!)
                completion(.success(fetchTwilioAccessTokenResponse.token))
            case .failure:
                guard let data = response.data else { completion(.failure(.other)); return }

                do {
                    let errorResponse = try jsonDecoder.decode(ErrorResponse.self, from: data)

                    switch errorResponse.error {
                    case .expired: completion(.failure(.expiredPasscode))
                    case .unauthorized: completion(.failure(.unauthorized))
                    }
                } catch {
                    completion(.failure(.other))
                }
            }
        }
    }
}

class SnakeCaseJSONDecoder: JSONDecoder {
    override init() {
        super.init()
        keyDecodingStrategy = .convertFromSnakeCase
    }
}

class SnakeCaseJSONEncoder: JSONEncoder {
    override init() {
        super.init()
        keyEncodingStrategy = .convertToSnakeCase
    }
}
