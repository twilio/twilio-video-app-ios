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

protocol AuthStoreWritingDelegate: AnyObject {
    func didSignIn(error: Error?)
    func didSignOut()
}

protocol AuthStoreWriting: AuthStoreReading, LaunchStore {
    var delegate: AuthStoreWritingDelegate? { get set }
    func start()
    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void)
    func signOut()
    func openURL(_ url: URL, sourceApplication: String?, annotation: Any?) -> Bool
}

protocol AuthStoreReading: AnyObject {
    var isSignedIn: Bool { get }
    var userDisplayName: String { get }
}

protocol AuthStoreTwilioAccessTokenFetching: AnyObject {
    func fetchTwilioAccessToken(roomName: String, completion: @escaping (String?, Error?) -> Void)
}

protocol AuthStoreEverything: AuthStoreWriting, AuthStoreTwilioAccessTokenFetching { }

class AuthStore: NSObject {
    static let shared: AuthStoreEverything = AuthStoreFactory().makeAuthStore()
}
