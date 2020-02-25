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

class CommunityAuthStore: AuthStoreEverything {
    weak var delegate: AuthStoreWritingDelegate?
    var isSignedIn: Bool { keychainStore.passcode != nil }
    var userDisplayName: String { appSettingsStore.userIdentity }
    private let appSettingsStore: AppSettingsStoreWriting
    private let tokenService: PasscodeTokenService = PasscodeTokenService()
    private let keychainStore: KeychainStoreWriting

    init(appSettingsStore: AppSettingsStoreWriting, keychainStore: KeychainStoreWriting) {
        self.appSettingsStore = appSettingsStore
        self.keychainStore = keychainStore
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
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.appSettingsStore.userIdentity = name
                self.keychainStore.passcode = passcode
                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func signOut() {
        keychainStore.passcode = nil
        appSettingsStore.userIdentity = ""
        delegate?.didSignOut()
    }

    func openURL(_ url: URL) -> Bool {
        return false
    }

    func fetchTwilioAccessToken(roomName: String, completion: @escaping (String?, Error?) -> Void) {
        tokenService.getToken(
            passcode: keychainStore.passcode ?? "", // Change?
            userIdentity: appSettingsStore.userIdentity,
            roomName: roomName
        ) { result in
            switch result {
            case let .success(token): completion(token.token, nil)
            case let .failure(error): completion(nil, error)
            }
        }
    }
}
