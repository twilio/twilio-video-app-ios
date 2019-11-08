//
//  AppCenterStore.swift
//  VideoApp
//
//  Created by Tim Rozum on 11/7/19.
//  Copyright © 2019 Twilio, Inc. All rights reserved.
//

import AppCenter
import AppCenterDistribute

@objc class AppCenterStore: NSObject {
    @objc func start() {
        guard let appSecret = CredentialsStore().credentials.appCenterAppSecret else { return }
        
        MSAppCenter.start(appSecret, withServices: [MSDistribute.self])
    }
}
