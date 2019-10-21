//
//  FirebaseAuthManager.swift
//  VideoApp
//
//  Created by Ryan Payne on 7/18/18.
//  Copyright © 2018 Twilio, Inc. All rights reserved.
//

import Firebase
import GoogleSignIn
import UIKit

class FirebaseAuthManager: NSObject {

    @objc class func currentUserDisplayName () -> String {
        guard let currentUser = Auth.auth().currentUser else {
            return "Unknown"
        }

        guard let displayName = currentUser.displayName else {
            guard let email = currentUser.email else {
                return "Unknown"
            }

            return email
        }

        return displayName
    }

    class func authenticate(email: String, password: String, window: UIWindow) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            handleAuthenticationResponse(user: user, error: error, window: window)
        }
    }

    @objc class func authenticate(credential: AuthCredential, window: UIWindow) {
        Auth.auth().signIn(with: credential) { (user, error) in
            handleAuthenticationResponse(user: user, error: error, window: window)
        }
    }

    private class func loginWasSuccessful(window: UIWindow) {
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

    private class func handleAuthenticationResponse(user: User?, error: Error?, window: UIWindow) {
        guard let error = error else {
            loginWasSuccessful(window: window)
            return
        }

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
