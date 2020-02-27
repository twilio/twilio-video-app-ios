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

class AuthFlow {
    private let window: UIWindow
    private let signInSegueIdentifierFactory: SignInSegueIdentifierFactory

    init(window: UIWindow, signInSegueIdentifierFactory: SignInSegueIdentifierFactory) {
        self.window = window
        self.signInSegueIdentifierFactory = signInSegueIdentifierFactory
    }
    
    private func showSignIn() {
        guard let rootViewController = window.rootViewController else {
            return
        }
        if let navigationController = rootViewController as? UINavigationController {
            navigationController.dismiss(animated: true) {
                navigationController.popToRootViewController(animated: true)
                navigationController.topViewController?.performSegue(
                    withIdentifier: self.signInSegueIdentifierFactory.makeSignInSegueIdentifier(),
                    sender: self
                )
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

    private func showError(error: AuthError) {
        let alertController = UIAlertController(title: "Sign In Error", message: error.message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        var topController = window.rootViewController!

        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }

        topController.present(alertController, animated: true, completion: nil)
    }
}

extension AuthFlow: AuthStoreWritingDelegate {
    func didSignIn(error: AuthError?) {
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

private extension AuthError {
    var message: String {
        switch self {
        case .expiredPasscode: return "The passcode has expired."
        case .wrongPasscode: return "The passcode is incorrect."
        case .userDisabled: return "The user account is disabled."
        case .invalidEmail: return "The email address was malformed."
        case .wrongPassword: return "The email address or password was incorrect."
        case .networkError: return "A network error occurred. Please try again."
        case .other: return "A sign in error has occurred. Please try again."
        }
    }
}
