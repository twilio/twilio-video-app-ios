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

@available(iOS 13, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var launchFlow: LaunchFlow?
    var launchFlowFactory: LaunchFlowFactory = LaunchFlowFactoryImpl()
    var urlOpenerFactory: URLOpenerFactory = URLOpenerFactoryImpl()
    var userActivityStoreFactory: UserActivityStoreFactory = UserActivityStoreFactoryImpl()
    var window: UIWindow?
    var windowSceneObserverFactory: WindowSceneObserverFactory = WindowSceneObserverFactoryImpl()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let windowScene = scene as! UIWindowScene
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        launchFlow = launchFlowFactory.makeLaunchFlow(window: window!)
        launchFlow?.start()

        if let userActivity = connectionOptions.userActivities.first {
            self.scene(scene, continue: userActivity)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        URLContexts.forEach { urlOpenerFactory.makeURLOpener().openURL($0.url) }
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        userActivityStoreFactory.makeUserActivityStore().continueUserActivity(userActivity)
    }

    func windowScene(
        _ windowScene: UIWindowScene,
        didUpdate previousCoordinateSpace: UICoordinateSpace,
        interfaceOrientation previousInterfaceOrientation: UIInterfaceOrientation,
        traitCollection previousTraitCollection: UITraitCollection
    ) {
        windowSceneObserverFactory.makeWindowSceneObserver().interfaceOrientationDidChange(windowScene: windowScene)
    }
}
