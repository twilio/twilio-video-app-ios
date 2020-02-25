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

import Foundation

class PasscodeAPI {
    struct RequestParameters: Codable {
        let passcode: String
        let userIdentity: String
        let roomName: String
    }

    enum Error: Swift.Error {
        case invalidPasscode
        case other(Swift.Error)
    }

    struct APITokenResponse: Codable {
        let token: String
    }

    struct APIErrorResponse: Codable {
        enum ErrorType: String, Codable {
            case expired
            case unauthorized
        }
        
        let type: ErrorType
    }

    func getToken(
        passcode: String,
        userIdentity: String,
        roomName: String,
        completion: @escaping (Result<APITokenResponse, APIError>) -> Void
    ) {
        let passcodeComponents = PasscodeComponents(string: passcode)
        
        let session = URLSession.shared
        let url = URL(string: "https://video-app-\(passcodeComponents.appID)-dev.twil.io/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = PasscodeRequestParameters(passcode: passcodeComponents.apiPasscode, userIdentity: userIdentity, roomName: roomName)
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try! jsonEncoder.encode(body)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request) { data, response, error in
            // Improve
            if (response as! HTTPURLResponse).statusCode == 200 {
                if let data = data {
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decodedResponse = try! jsonDecoder.decode(APITokenResponse.self, from: data)

                    DispatchQueue.main.async {
                        completion(.success(decodedResponse))
                    }
                }
            } else {
                print("Error: \(String(describing: error))")
            }
        }
        
        task.resume()
    }
}
