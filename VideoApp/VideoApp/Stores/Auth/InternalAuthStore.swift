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

class InternalAuthStore: NSObject, AuthStoreWriting {
    weak var delegate: AuthStoreWritingDelegate?
    var isSignedIn: Bool { firebaseAuth.currentUser != nil }
    var passcode: String? { nil } // Not used for internal auth
    var userDisplayName: String { firebaseAuth.currentUser?.displayName ?? firebaseAuth.currentUser?.email ?? "Unknown" }
    private let api: APIConfiguring
    private let appSettingsStore: AppSettingsStoreWriting
    private var firebaseAuth: Auth { return Auth.auth() }
    private var googleSignIn: GIDSignIn { return GIDSignIn.sharedInstance }

    init(api: APIConfiguring, appSettingsStore: AppSettingsStoreWriting) {
        self.api = api
        self.appSettingsStore = appSettingsStore
    }
    
    func start() {
        FirebaseApp.configure()
    }

    func signIn(googleSignInPresenting: UIViewController) {
        let config = GIDConfiguration(
            clientID: FirebaseApp.app()!.options.clientID!,
            serverClientID: nil,
            hostedDomain: "twilio.com",
            openIDRealm: nil
        )

        googleSignIn.signIn(with: config, presenting: googleSignInPresenting) { [weak self] user, error in
            if let error = error {
                self?.delegate?.didSignIn(error: AuthError.message(message: error.localizedDescription))
                return
            }
            
            guard let authentication = user?.authentication, let idToken = authentication.idToken else {
                self?.delegate?.didSignIn(error: AuthError.unknown)
                return
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: authentication.accessToken
            )

            self?.firebaseAuth.signIn(with: credential) { _, error in
                if let error = error {
                    self?.delegate?.didSignIn(error: AuthError(firebaseAuthError: error))
                } else {
                    self?.delegate?.didSignIn(error: nil)
                }
            }
        }
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
        googleSignIn.disconnect { [weak self] _ in
            self?.appSettingsStore.reset()
            self?.delegate?.didSignOut()
        }
    }

    func openURL(_ url: URL) -> Bool {
        googleSignIn.handle(url)
    }

    func refreshIDToken(completion: @escaping () -> Void) {
        guard let user = firebaseAuth.currentUser else { completion(); return }
        
        user.getIDTokenForcingRefresh(true) { [weak self] idToken, error in
            guard let self = self else { return }
            
            if let idToken = idToken {
                self.api.config = APIConfig(host: self.appSettingsStore.environment.host, idToken: idToken)
            }
            
            completion()
        }
    }
}

private extension TwilioEnvironment {
    var host: String {
        switch self {
        case .production: return "twilio-video-react.appspot.com"
        case .staging: return "stage-dot-twilio-video-react.appspot.com"
        case .development: return "dev-dot-twilio-video-react.appspot.com"
        }
    }
}

private extension AuthError {
    init(firebaseAuthError: Error) {
        let code = AuthErrorCode(_nsError: firebaseAuthError as NSError).code
        
        switch code {
        case .userDisabled: self = .userDisabled
        case .invalidEmail: self = .invalidEmail
        case .userNotFound, .wrongPassword: self = .wrongPassword
        case .networkError: self = .networkError
        default: self = .unknown
        }
    }
}
