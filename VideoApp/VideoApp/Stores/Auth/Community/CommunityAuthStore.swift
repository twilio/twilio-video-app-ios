//
//  Copyright (C) 2019 Twilio, Inc.
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
import KeychainAccess

class CommunityAuthStore: AuthStoreEverything {
    weak var delegate: AuthStoreWritingDelegate?
    var isSignedIn: Bool { passcodeStore.passcode != nil }
    var userDisplayName: String { appSettingsStore.userIdentity }
    private let appSettingsStore: AppSettingsStoreWriting
    private let tokenService: PasscodeTokenService = PasscodeTokenService()
    private let passcodeStore = PasscodeStore()

    init(appSettingsStore: AppSettingsStoreWriting) {
        self.appSettingsStore = appSettingsStore
    }

    func start() {

    }

    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        
    }
    
    func signIn(name: String, passcode: String, completion: @escaping (Result<Void, APIError>) -> Void) {
        tokenService.getToken(
            passcode: passcode,
            userIdentity: name,
            roomName: UUID().uuidString
        ) { [weak self] result in
            // Make sure this is called on main thread
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.appSettingsStore.userIdentity = name
                self.passcodeStore.passcode = passcode
                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func signOut() {
        passcodeStore.passcode = nil
        appSettingsStore.userIdentity = ""
        delegate?.didSignOut()
    }

    func openURL(_ url: URL) -> Bool {
        return false
    }

    func fetchTwilioAccessToken(roomName: String, completion: @escaping (String?, Error?) -> Void) {
        tokenService.getToken(
            passcode: passcodeStore.passcode ?? "", // Change?
            userIdentity: appSettingsStore.userIdentity,
            roomName: roomName
        ) { result in
            // Make sure this is called on main thread

            switch result {
            case let .success(token): completion(token.token, nil)
            case let .failure(error): completion(nil, error)
            }
        }
    }
}

class PasscodeTokenService {
    func getToken(
        passcode: String,
        userIdentity: String,
        roomName: String,
        completion: @escaping (Result<APITokenResponse, APIError>) -> Void
    ) {
        let passcodeComponents = Passcode(fullPasscode: passcode)
        
        let session = URLSession.shared
        let url = URL(string: "https://video-app-\(passcodeComponents.appID)-dev.twil.io/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = PasscodeRequestInput(passcode: passcodeComponents.passcode, userIdentity: userIdentity, roomName: roomName)
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

class PasscodeStore {
    var passcode: String? {
        get {
            keychain["passcode"]
        }
        set {
            keychain["passcode"] = newValue
        }
    }
    private let keychain = Keychain()
}

struct Passcode {
    let passcode: String
    let appID: String
    
    init(fullPasscode: String) {
        passcode = String(fullPasscode.prefix(6))
        appID = String(fullPasscode.dropFirst(6))
    }
}

struct PasscodeRequestInput: Codable {
    let passcode: String
    let userIdentity: String
    let roomName: String
}

enum APIError: Error {
    case invalidPasscode
    case other(Error)
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
