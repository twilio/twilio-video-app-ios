//
//  SceneDelegate.swift
//  VideoApp
//
//  Created by Chris Eagleston on 9/11/19.
//  Copyright © 2019 Twilio, Inc. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import TwilioVideo

// Ensure that iOS 13 specific code is not called anywhere else unless the OS is available
@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // UIWindowScene delegate

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print(#function)
        GIDSignIn.sharedInstance()?.delegate = self

        // The `window` property will automatically be loaded with the storyboard's initial view controller.
        guard let navigationVC = self.window?.rootViewController as? UINavigationController else {
            return
        }
        // Despite the header doc claims, it is possible for recognizer to be triggered on iOS 13 even when hidesBarOnSwipe == false.
        navigationVC.barHideOnSwipeGestureRecognizer.isEnabled = false
        navigationVC.hidesBarsOnSwipe = false

        if let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
            if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
                // TODO: Deep linking support.
                if let lobby = navigationVC.topViewController as? LobbyViewController {
                    lobby.handleDeepLinkedURL(userActivity.webpageURL)
                }
            }
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts {
            if GIDSignIn.sharedInstance()!.handle(context.url,
                                                  sourceApplication: context.options.sourceApplication,
                                                  annotation: context.options.annotation) {
                break
            }
        }
    }

    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        return scene.userActivity
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        print(#function)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        print(#function)

        guard let navigationVC = self.window?.rootViewController as? UINavigationController,
            navigationVC.viewControllers.count == 1 else {
            return
        }

        if Auth.auth().currentUser != nil || GIDSignIn.sharedInstance()?.hasAuthInKeychain() == true {
            navigationVC.topViewController?.performSegue(withIdentifier: "lobbySegue", sender: self)
        } else {
            navigationVC.topViewController?.performSegue(withIdentifier: "loginSegue", sender: self)
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        print(#function)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        print(#function)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        print(#function)
    }

    func windowScene(_ windowScene: UIWindowScene,
                     didUpdate previousCoordinateSpace: UICoordinateSpace,
                     interfaceOrientation previousInterfaceOrientation: UIInterfaceOrientation,
                     traitCollection previousTraitCollection: UITraitCollection) {
        print("Window scene did update. prev: \(previousCoordinateSpace) \(previousInterfaceOrientation) \(previousTraitCollection)")

        UserInterfaceTracker.sceneInterfaceOrientationDidChange(windowScene)
    }

}

@available(iOS 13.0, *)
extension SceneDelegate : GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard let theError = error else {
            let auth = user.authentication!

            // Validate that the email address is indeed a twilio.com email address, else fail!
            if let email = user?.profile?.email,
                !email.hasSuffix("twilio.com") {
                let alertController = UIAlertController(title: "Unauthorized",
                                                        message: "Only users with a Twilio email address are authorized to use this application.",
                                                        preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Okay", style: .default) { (action) in
                }
                alertController.addAction(okAction)
                self.window?.rootViewController?.presentedViewController?.present(alertController,
                                                                                  animated: true,
                                                                                  completion: nil)
                GIDSignIn.sharedInstance()?.disconnect()
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
            FirebaseAuthManager.authenticate(credential: credential, window: self.window!)
            return
        }

        print("An authentication error occurred: \(theError)")
    }

    func sign(_ signIn: GIDSignIn!,
              didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        guard let rootViewController = self.window?.rootViewController else {
            return
        }
        if let navigationController = rootViewController as? UINavigationController {
            navigationController.popToRootViewController(animated: true)
            navigationController.topViewController?.performSegue(withIdentifier: "loginSegue", sender: self)
        }
    }
}
