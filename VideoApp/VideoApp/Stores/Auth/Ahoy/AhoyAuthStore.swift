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

class AhoyAuthStore: NSObject, AuthStoreEverything {
    weak var delegate: AuthStoreWritingDelegate?
    var isSignedIn: Bool { return firebaseAuthStore.isSignedIn }
    var userDisplayName: String { return firebaseAuthStore.userDisplayName }
    private let api: APIConfiguring & APIRequesting
    private let appSettingsStore: AppSettingsStoreWriting
    private let firebaseAuthStore: FirebaseAuthStoreWriting

    init(
        api: APIConfiguring & APIRequesting,
        appSettingsStore: AppSettingsStoreWriting,
        firebaseAuthStore: FirebaseAuthStoreWriting
    ) {
        self.api = api
        self.appSettingsStore = appSettingsStore
        self.firebaseAuthStore = firebaseAuthStore
    }
    
    func start() {
        firebaseAuthStore.delegate = self
        firebaseAuthStore.start()
    }
    
    func signIn(email: String, password: String, completion: @escaping (AuthError?) -> Void) {
        firebaseAuthStore.signIn(email: email, password: password, completion: completion)
    }

    func signIn(userIdentity: String, passcode: String, completion: @escaping (AuthError?) -> Void) {
        print("Passcode sign in not supported by Firebase auth.")
    }

    func signOut() {
        firebaseAuthStore.signOut()
    }

    func openURL(_ url: URL) -> Bool {
        return firebaseAuthStore.openURL(url)
    }

    func fetchTwilioAccessToken(roomName: String, completion: @escaping (String?, Error?) -> Void) {
        firebaseAuthStore.fetchAccessToken { [weak self] accessToken, error in
            guard let self = self, let accessToken = accessToken else { completion(nil, error); return }
            
            let host = "https://app.\(self.appSettingsStore.environment.qualifier)video.bytwilio.com"
            self.api.config = APIConfig(host: host, accessToken: accessToken)

            let parameters = CreateFirebaseTwilioAccessTokenRequest.Parameters(
                identity: self.appSettingsStore.userIdentity.nilIfEmpty ?? self.userDisplayName,
                roomName: roomName,
                topology: .init(topology: self.appSettingsStore.topology)
            )
            
            let request = CreateFirebaseTwilioAccessTokenRequest(parameters: parameters)
            
            self.api.request(request) { result in
                switch result {
                case let .success(accessToken): completion(accessToken, nil)
                case let .failure(error): completion(nil, error)
                }
            }
        }
    }
}

extension AhoyAuthStore: AuthStoreWritingDelegate {
    func didSignIn(error: AuthError?) {
        delegate?.didSignIn(error: error)
    }
    
    func didSignOut() {
        appSettingsStore.reset()
        delegate?.didSignOut()
    }
}

private extension Environment {
    var qualifier: String {
        switch self {
        case .production: return ""
        case .staging: return "stage."
        case .development: return "dev."
        }
    }
}

private extension CreateFirebaseTwilioAccessTokenRequest.Parameters.Topology {
    init(topology: Topology) {
        switch topology {
        case .group: self = .group
        case .peerToPeer: self = .peerToPeer
        }
    }
}
