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

class PasscodeAPI: PasscodeAPIWriting {
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
            passcode: passcodeComponents.passcode,
            userIdentity: userIdentity,
            roomName: roomName
        )
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        let jsonParameterEncoder = JSONParameterEncoder(encoder: jsonEncoder)
        
        session.request(url, method: .post, parameters: parameters, encoder: jsonParameterEncoder).validate().response { response in
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

            switch response.result {
            case let .success(data):
                do {
                    let fetchTwilioAccessTokenResponse = try jsonDecoder.decode(FetchTwilioAccessTokenResponse.self, from: data!)
                    completion(.success(fetchTwilioAccessTokenResponse.token))
                } catch {
                    completion(.failure(.decodeError))
                }
            case .failure:
                guard let data = response.data else { completion(.failure(.decodeError)); return }

                do {
                    let errorResponse = try jsonDecoder.decode(ErrorResponse.self, from: data)

                    completion(.failure(PasscodeAPIError(responseError: errorResponse.error)))
                } catch {
                    completion(.failure(.decodeError))
                }
            }
        }
    }
}

private extension PasscodeAPIError {
    init(responseError: PasscodeAPI.ErrorResponse.Error) {
        switch responseError {
        case .expired: self = .expiredPasscode
        case .unauthorized: self = .unauthorized
        }
    }
}
