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

class InternalAuthStore: NSObject, AuthStoreEverything {
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
        fatalError("Passcode sign in not supported by Firebase auth.")
    }

    func signOut() {
        firebaseAuthStore.signOut()
    }

    func openURL(_ url: URL) -> Bool {
        return firebaseAuthStore.openURL(url)
    }

    func fetchTwilioAccessToken(roomName: String, completion: @escaping (String?, AuthError?) -> Void) {
        firebaseAuthStore.fetchAccessToken { [weak self] accessToken, error in
            guard let self = self, let accessToken = accessToken else { completion(nil, .unknown); return }
            
            self.api.config = APIConfig(host: self.appSettingsStore.environment.host, accessToken: accessToken)

            let request = InternalCreateTwilioAccessTokenRequest(
                identity: self.appSettingsStore.userIdentity.nilIfEmpty ?? self.userDisplayName,
                roomName: roomName,
                topology: .init(topology: self.appSettingsStore.topology)
            )
            
            self.api.request(request) { result in
                switch result {
                case let .success(accessToken): completion(accessToken, nil)
                case let .failure(error): completion(nil, AuthError(apiError: error))
                }
            }
        }
    }
}

extension InternalAuthStore: AuthStoreWritingDelegate {
    func didSignIn(error: AuthError?) {
        delegate?.didSignIn(error: error)
    }
    
    func didSignOut() {
        appSettingsStore.reset()
        delegate?.didSignOut()
    }
}

private extension Environment {
    var host: String {
        switch self {
        case .production: return "app.video.bytwilio.com/api/v1"
        case .staging: return "app.stage.video.bytwilio.com/api/v1"
        case .development: return "app.dev.video.bytwilio.com/api/v1"
        }
    }
}

private extension InternalCreateTwilioAccessTokenRequest.Parameters.Topology {
    init(topology: Topology) {
        switch topology {
        case .group: self = .group
        case .peerToPeer: self = .peerToPeer
        }
    }
}
