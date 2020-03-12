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
    private let keychainStore: KeychainStoreWriting
    private let api: APIConfiguring & APIRequesting

    init(
        appSettingsStore: AppSettingsStoreWriting,
        keychainStore: KeychainStoreWriting,
        api: APIConfiguring & APIRequesting
    ) {
        self.appSettingsStore = appSettingsStore
        self.keychainStore = keychainStore
        self.api = api
    }

    func start() {
        guard let passcode = keychainStore.passcode else { return }
        
        configureAPI(passcode: passcode)
    }

    func signIn(email: String, password: String, completion: @escaping (AuthError?) -> Void) {
        print("Email sign in not supported by community auth.")
    }

    func signIn(userIdentity: String, passcode: String, completion: @escaping (AuthError?) -> Void) {
        configureAPI(passcode: passcode)
        let request = CreateTwilioAccessTokenRequest(passcode: passcode, userIdentity: userIdentity, roomName: "")
        
        api.request(request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.keychainStore.passcode = passcode
                self.appSettingsStore.userIdentity = userIdentity
                completion(nil)
            case let .failure(error):
                self.api.config = nil
                completion(AuthError(apiError: error))
            }
        }
    }

    func signOut() {
        keychainStore.passcode = nil
        appSettingsStore.reset()
        api.config = nil
        delegate?.didSignOut()
    }

    func openURL(_ url: URL) -> Bool {
        return false
    }

    func fetchTwilioAccessToken(roomName: String, completion: @escaping (String?, Error?) -> Void) {
        let request = CreateTwilioAccessTokenRequest(
            passcode: keychainStore.passcode ?? "",
            userIdentity: appSettingsStore.userIdentity,
            roomName: roomName
        )
        
        api.request(request) { result in
            switch result {
            case let .success(response): completion(response.token, nil)
            case let .failure(error): completion(nil, error)
            }
        }
    }
    
    private func configureAPI(passcode: String) {
        let host = "video-app-\(PasscodeComponents(string: passcode).appID)-dev.twil.io"
        api.config = APIConfig(host: host)
    }
}
