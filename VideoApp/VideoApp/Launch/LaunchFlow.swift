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

@objc protocol LaunchFlow {
    func start()
}

@objc class LaunchFlowImpl: NSObject, LaunchFlow {
    private let window: UIWindow
    private let authFlow: AuthStoreWritingDelegate
    private let authStore: AuthStoreWriting
    
    init(window: UIWindow, authFlow: AuthStoreWritingDelegate, authStore: AuthStoreWriting) {
        self.window = window
        self.authFlow = authFlow
        self.authStore = authStore
    }
    
    func start() {
        authStore.delegate = authFlow

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window.rootViewController = storyboard.instantiateInitialViewController()
        window.makeKeyAndVisible()

        let navigationController = window.rootViewController as! UINavigationController
        navigationController.barHideOnSwipeGestureRecognizer.isEnabled = false
        navigationController.hidesBarsOnSwipe = false
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleApplicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc func handleApplicationDidBecomeActive() {
        let navigationController = UIApplication.shared.windows[0].rootViewController as? UINavigationController
        
        guard navigationController?.viewControllers.count == 1 else { return }

        let segueIdentifier = AuthStore.shared.isSignedIn ? "lobbySegue" : "loginSegue"
        navigationController?.topViewController?.performSegue(withIdentifier: segueIdentifier, sender: self)
    }
}
