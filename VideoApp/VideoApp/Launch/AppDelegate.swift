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

import TwilioVideo
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var launchStoresFactory: LaunchStoresFactory = LaunchStoresFactoryImpl()
    var launchFlow: LaunchFlow?
    var launchFlowFactory: LaunchFlowFactory = LaunchFlowFactoryImpl()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        launchStoresFactory.makeLaunchStores().forEach { $0.start() }

        TwilioVideoSDK.setLogLevel(.info)

        if #available(iOS 13, *) {
            // Do nothing because SceneDelegate will handle it
        } else {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.launchFlow = launchFlowFactory.makeLaunchFlow(window: window!)
            self.launchFlow?.start()
        }

        return true
    }

    @available(iOS 13, *)
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return AuthStore.shared.openURL(
            url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.sourceApplication]
        )
    }
}
