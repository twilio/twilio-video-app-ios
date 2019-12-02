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
    var delegate: AuthStoreWritingDelegate? {
        get { return firebaseAuthStore.delegate }
        set { firebaseAuthStore.delegate = newValue }
    }
    var isSignedIn: Bool { return firebaseAuthStore.isSignedIn }
    var userDisplayName: String { return firebaseAuthStore.userDisplayName }
    private let api: TwilioVideoAppAPIProtocol
    private let appSettingsStore: AppSettingsStoreWriting
    private let firebaseAuthStore: FirebaseAuthStoreWriting

    init(
        api: TwilioVideoAppAPIProtocol,
        appSettingsStore: AppSettingsStoreWriting,
        firebaseAuthStore: FirebaseAuthStoreWriting
    ) {
        self.api = api
        self.appSettingsStore = appSettingsStore
        self.firebaseAuthStore = firebaseAuthStore
    }
    
    func start() {
        firebaseAuthStore.start()
    }
    
    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        firebaseAuthStore.signIn(email: email, password: password, completion: completion)
    }
    
    func signOut() {
        firebaseAuthStore.signOut()
    }

    func openURL(_ url: URL, sourceApplication: String?, annotation: Any?) -> Bool {
        return firebaseAuthStore.openURL(url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func fetchTwilioAccessToken(roomName: String, completion: @escaping (String?, Error?) -> Void) {
        firebaseAuthStore.fetchAccessToken { [weak self] accessToken, error in
            guard let self = self, let accessToken = accessToken else { completion(nil, error); return }
            
            self.api.retrieveAccessToken(
                forIdentity: self.appSettingsStore.userIdentity.nilIfEmpty ?? self.userDisplayName,
                roomName: roomName,
                authToken: accessToken,
                environment: self.appSettingsStore.apiEnvironment.legacyAPIEnvironment,
                topology: self.appSettingsStore.topology.apiTopology
            ) { accessToken, error in
                completion(accessToken, error)
            }
        }
    }
}

private extension Topology {
    var apiTopology: TwilioVideoAppAPITopology {
        switch self {
        case .group: return .group
        case .peerToPeer: return .P2P
        }
    }
}

private extension APIEnvironment {
    var legacyAPIEnvironment: TwilioVideoAppAPIEnvironment {
        switch self {
        case .production: return .production
        case .staging: return .staging
        case .development: return .development
        }
    }
}
