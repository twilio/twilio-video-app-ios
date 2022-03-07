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

import SwiftUI
import UIKit

protocol LaunchFlow {
    func start()
}

class LaunchFlowImpl: LaunchFlow {
    private let window: UIWindow
    private let authFlow: AuthStoreWritingDelegate
    private let authStore: AuthStoreWriting
    private let deepLinkStore: DeepLinkStoreWriting
    private let signInSegueIdentifierFactory: SignInSegueIdentifierFactory
    
    init(
        window: UIWindow,
        authFlow: AuthStoreWritingDelegate,
        authStore: AuthStoreWriting,
        deepLinkStore: DeepLinkStoreWriting,
        signInSegueIdentifierFactory: SignInSegueIdentifierFactory
    ) {
        self.window = window
        self.authFlow = authFlow
        self.authStore = authStore
        self.deepLinkStore = deepLinkStore
        self.signInSegueIdentifierFactory = signInSegueIdentifierFactory
    }
    
    func start() {
        authStore.delegate = authFlow

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window.rootViewController = storyboard.instantiateInitialViewController()
        window.makeKeyAndVisible()

        let navigationController = window.rootViewController as! UINavigationController
        navigationController.barHideOnSwipeGestureRecognizer.isEnabled = false
        navigationController.hidesBarsOnSwipe = false

        if authStore.isSignedIn {
            let homeController = UIHostingController(rootView: HomeView())
            homeController.modalPresentationStyle = .fullScreen
            navigationController.present(homeController, animated: true)
        } else {
            navigationController.topViewController?.performSegue(
                withIdentifier: signInSegueIdentifierFactory.makeSignInSegueIdentifier(),
                sender: self
            )
        }
        
        deepLinkStore.didReceiveDeepLink = { [weak self] in
            self?.start()
        }
    }
}
