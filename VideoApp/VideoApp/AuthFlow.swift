//
//  AuthFlow.swift
//  VideoApp
//
//  Created by Tim Rozum on 10/22/19.
//  Copyright © 2019 Twilio, Inc. All rights reserved.
//

import UIKit
import Firebase

@objc class AuthFlow: NSObject {
    private let window: UIWindow
    
    @objc init(window: UIWindow) {
        self.window = window
    }
    
    private func showSignIn() {
        guard let rootViewController = window.rootViewController else {
            return
        }
        if let navigationController = rootViewController as? UINavigationController {
            navigationController.popToRootViewController(animated: true)
            navigationController.topViewController?.performSegue(withIdentifier: "loginSegue", sender: self)
        }
    }

    private func showInvalidEmail() {
        let alertController = UIAlertController(title: "Unauthorized",
                                                message: "Only users with a Twilio email address are authorized to use this application.",
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Okay", style: .default) { (action) in
        }
        alertController.addAction(okAction)
        window.rootViewController?.presentedViewController?.present(alertController,
                                                                          animated: true,
                                                                          completion: nil)
    }

    private func showLobby() {
        guard let navigationVC = window.rootViewController as? UINavigationController else {
            return
        }
        // TODO: This logic should live in SceneDelegate or AppDelegate as a completion block.
        assert(Auth.auth().currentUser != nil)
        if #available(iOS 13.0, *) {
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
    func didSignIn(error: Error?, isValidEmail: Bool) {
        if isValidEmail {
            if let error = error {
                showError(error: error)
            } else {
                showLobby()
            }
        } else {
            showInvalidEmail()
        }
    }
    
    func didSignOut() {
        showSignIn()
    }
}
