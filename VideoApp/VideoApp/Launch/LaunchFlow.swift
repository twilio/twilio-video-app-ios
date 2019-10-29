//
//  LaunchFlow.swift
//  VideoApp
//
//  Created by Tim Rozum on 10/31/19.
//  Copyright © 2019 Twilio, Inc. All rights reserved.
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
    }
}
