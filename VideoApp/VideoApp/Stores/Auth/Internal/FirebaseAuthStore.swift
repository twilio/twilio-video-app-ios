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
    func fetchAccessToken(completion: @escaping (Result<String, AuthError>) -> Void)
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
    
    func signIn(email: String, password: String, completion: @escaping (AuthError?) -> Void) {
        firebaseAuth.signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                completion(AuthError(firebaseAuthError: error))
            } else {
                completion(nil)
            }
        }
    }

    func signIn(userIdentity: String, passcode: String, completion: @escaping (AuthError?) -> Void) {
        fatalError("Passcode sign in not supported by Firebase auth.")
    }

    func signOut() {
        try? firebaseAuth.signOut()
        googleSignIn.signOut()
        googleSignIn.disconnect()
    }

    func openURL(_ url: URL) -> Bool {
        return googleSignIn.handle(url)
    }
    
    func fetchAccessToken(completion: @escaping (Result<String, AuthError>) -> Void) {
        guard let user = firebaseAuth.currentUser else { completion(.failure(.unknown)); return }
        
        user.getIDTokenForcingRefresh(true) { accessToken, error in
            if let accessToken = accessToken {
                completion(.success(accessToken))
            } else if let error = error {
                completion(.failure(AuthError(firebaseAuthError: error)))
            } else {
                completion(.failure(.unknown))
            }
        }
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
            if let error = error {
                self?.delegate?.didSignIn(error: AuthError(firebaseAuthError: error))
            } else {
                self?.delegate?.didSignIn(error: nil)
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        delegate?.didSignOut()
    }
}

private extension AuthError {
    init(firebaseAuthError: Error) {
        guard let code = AuthErrorCode(rawValue: (firebaseAuthError as NSError).code) else { self = .unknown; return }
        
        switch code {
        case .userDisabled: self = .userDisabled
        case .invalidEmail: self = .invalidEmail
        case .userNotFound, .wrongPassword: self = .wrongPassword
        case .networkError: self = .networkError
        default: self = .unknown
        }
    }
}
