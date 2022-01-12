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

class CommunityAuthStore: AuthStoreWriting {
    weak var delegate: AuthStoreWritingDelegate?
    var isSignedIn: Bool { keychainStore.passcode != nil }
    var passcode: String? { keychainStore.passcode }
    var userDisplayName: String { appSettingsStore.userIdentity }
    private let api: APIConfiguring & APIRequesting
    private let appSettingsStore: AppSettingsStoreWriting
    private let keychainStore: KeychainStoreWriting
    private let remoteConfigStore: RemoteConfigStoreWriting

    init(
        api: APIConfiguring & APIRequesting,
        appSettingsStore: AppSettingsStoreWriting,
        keychainStore: KeychainStoreWriting,
        remoteConfigStore: RemoteConfigStoreWriting
    ) {
        self.api = api
        self.appSettingsStore = appSettingsStore
        self.keychainStore = keychainStore
        self.remoteConfigStore = remoteConfigStore
    }

    func start() {
        guard let passcode = keychainStore.passcode else { return }
        
        try? configureAPI(passcode: passcode)
    }

    func signIn(googleSignInPresenting: UIViewController) {
        fatalError("Google sign in not supported by community auth.")
    }
    
    func signIn(email: String, password: String, completion: @escaping (AuthError?) -> Void) {
        fatalError("Email sign in not supported by community auth.")
    }

    func signIn(userIdentity: String, passcode: String, completion: @escaping (AuthError?) -> Void) {
        guard (try? configureAPI(passcode: passcode)) != nil else { completion(.passcodeIncorrect); return }

        let request = CreateTwilioAccessTokenRequest(
            passcode: passcode,
            userIdentity: userIdentity,
            createRoom: false
        )
        
        api.request(request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(response):
                self.keychainStore.passcode = passcode
                self.appSettingsStore.userIdentity = userIdentity
                
                if let roomType = response.roomType {
                    self.remoteConfigStore.roomType = roomType
                }
                
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

    func refreshIDToken(completion: @escaping () -> Void) {
        completion() // Do nothing for community auth
    }
    
    private func configureAPI(passcode: String) throws {
        let passcodeComponents = try PasscodeComponents(string: passcode)
        
        var appID: String {
            guard let appID = passcodeComponents.appID else { return "" }
            
            return "\(appID)-"
        }
        
        let host = "video-app-\(appID)\(passcodeComponents.serverlessID)-dev.twil.io"
        api.config = APIConfig(host: host)
    }
}
