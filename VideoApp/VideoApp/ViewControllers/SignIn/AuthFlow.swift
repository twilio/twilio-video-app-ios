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

import UIKit
import Firebase

class AuthFlow {
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    private func showSignIn() {
        guard let rootViewController = window.rootViewController else {
            return
        }
        if let navigationController = rootViewController as? UINavigationController {
            navigationController.dismiss(animated: true) {
                navigationController.popToRootViewController(animated: true)

                let segueIdentifier: String
                
                // Inject
                switch AppInfoStoreFactory().makeAppInfoStore().appInfo.target {
                case .videoTwilio, .videoInternal: segueIdentifier = "loginSegue"
                case .videoCommunity: segueIdentifier = "passcodeSignIn"
                }

                navigationController.topViewController?.performSegue(withIdentifier: segueIdentifier, sender: self)
            }
        }
    }

    private func showLobby() {
        guard let navigationVC = window.rootViewController as? UINavigationController else {
            return
        }

        if #available(iOS 13, *) {
            navigationVC.dismiss(animated: true) {
                navigationVC.popToRootViewController(animated: true)
                navigationVC.viewControllers.first?.performSegue(withIdentifier: "lobbySegue", sender: self)
            }
        } else {
            if navigationVC.presentedViewController != nil {
                navigationVC.dismiss(animated: true) {
                    navigationVC.popToRootViewController(animated: true)
                    navigationVC.viewControllers.first?.performSegue(withIdentifier: "lobbySegue", sender: self)
                }
            } else {
                navigationVC.popToRootViewController(animated: true)
                navigationVC.viewControllers.first?.performSegue(withIdentifier: "lobbySegue", sender: self)
            }
        }
    }

    private func showError(error: Error) {
        guard let errorCode = AuthErrorCode(rawValue: error._code) else {
            return
        }

        var errorMessage: String

        switch (errorCode) {
        case .userDisabled:
            // Indicates the user's account is disabled.
            errorMessage = "The user account is disabled."
            break
        case .invalidEmail:
            // Indicates the email address is malformed.
            errorMessage = "The email address was malformed."
            break
        case .userNotFound:
            // Indicates the user account was not found.
            fallthrough
        case .wrongPassword:
            // Indicates the user attempted sign in with an incorrect password, if credential is of the type EmailPasswordAuthCredential.
            errorMessage = "The email address or password was incorrect."
            break
        case .networkError:
            // Indicates a network error occurred (such as a timeout, interrupted connection, or unreachable host). These types of
            // errors are often recoverable with a retry. The NSUnderlyingError field in the NSError.userInfo dictionary will contain
            // the error encountered.
            errorMessage = "A network error occurred. Please try authenticating again."
            break
        default:
            // Any other of the litany of errors that could occur
            errorMessage = "An authentication error has occurred. Please try authenticating again."
            break
        }

        let alertController = UIAlertController(title: "AuthenticationError", message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        var topController = window.rootViewController!

        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }

        topController.present(alertController, animated: true, completion: nil)
    }
}

extension AuthFlow: AuthStoreWritingDelegate {
    func didSignIn(error: Error?) {
        if let error = error {
            showError(error: error)
        } else {
            showLobby()
        }
    }
    
    func didSignOut() {
        showSignIn()
    }
}
