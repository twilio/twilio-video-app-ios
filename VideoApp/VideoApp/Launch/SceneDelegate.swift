//
//  SceneDelegate.swift
//  VideoApp
//
//  Created by Chris Eagleston on 9/11/19.
//  Copyright © 2019 Twilio, Inc. All rights reserved.
//

import UIKit
import TwilioVideo

@available(iOS 13, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var launchFlow: LaunchFlow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let windowScene = scene as! UIWindowScene
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene

        launchFlow = LaunchFlowFactory().makeLaunchFlow(window: window!)
        launchFlow?.start()
        
        if let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
            if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
                if let lobby = (window?.rootViewController as? UINavigationController)?.topViewController as? LobbyViewController {
                    lobby.handleDeepLinkedURL(userActivity.webpageURL)
                }
            }
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts {
            let didOpenURL = AuthStore.shared.openURL(
                context.url,
                sourceApplication: context.options.sourceApplication,
                annotation: context.options.annotation
            )
            
            if didOpenURL { break }
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

        
        if AuthStore.shared.isSignedIn {
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
