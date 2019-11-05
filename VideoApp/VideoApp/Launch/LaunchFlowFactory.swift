//
//  LaunchFlowFactory.swift
//  VideoApp
//
//  Created by Tim Rozum on 11/1/19.
//  Copyright © 2019 Twilio, Inc. All rights reserved.
//

import UIKit

@objc class LaunchFlowFactory: NSObject {
    @objc func makeLaunchFlow(window: UIWindow) -> LaunchFlow {
        return LaunchFlowImpl(
            window: window,
            authFlow: AuthFlow(window: window),
            authStore: AuthStore.shared
        )
    }
}
