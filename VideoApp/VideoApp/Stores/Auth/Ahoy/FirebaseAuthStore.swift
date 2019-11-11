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

import Firebase
import GoogleSignIn

protocol FirebaseAuthStoreWriting: AuthStoreWriting {
    func fetchAccessToken(completion: @escaping (String?, Error?) -> Void)
}

class FirebaseAuthStore: NSObject, FirebaseAuthStoreWriting {
    weak var delegate: AuthStoreWritingDelegate?
    private var firebaseAuth: Auth { return Auth.auth() }
    private var googleSignIn: GIDSignIn { return GIDSignIn.sharedInstance() }
    
    var isSignedIn: Bool {
        return firebaseAuth.currentUser != nil
    }

    var userDisplayName: String {
        return firebaseAuth.currentUser?.displayName ?? firebaseAuth.currentUser?.email ?? "Unknown"
    }
    
    func start() {
        FirebaseApp.configure()
        googleSignIn.clientID = FirebaseApp.app()?.options.clientID
        googleSignIn.hostedDomain = "twilio.com"
        googleSignIn.delegate = self
    }
    
    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        firebaseAuth.signIn(withEmail: email, password: password) { _, error in
            completion(error)
        }
    }
    
    func signOut() {
        try? firebaseAuth.signOut()
        googleSignIn.signOut()
        googleSignIn.disconnect()
    }

    func openURL(_ url: URL, sourceApplication: String?, annotation: Any?) -> Bool {
        return googleSignIn.handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func fetchAccessToken(completion: @escaping (String?, Error?) -> Void) {
        guard let user = firebaseAuth.currentUser else { completion(nil, nil); return }
        
        user.getIDTokenForcingRefresh(true, completion: completion)
    }
}

extension FirebaseAuthStore: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil, let authentication = user.authentication else { return }
        
        let credential = GoogleAuthProvider.credential(
            withIDToken: authentication.idToken,
            accessToken: authentication.accessToken
        )

        firebaseAuth.signIn(with: credential) { [weak self] _, error in
            self?.delegate?.didSignIn(error: error)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        delegate?.didSignOut()
    }
}
