//
//  TwilioAccessTokenServiceFactory.swift
//  VideoApp
//
//  Created by Tim Rozum on 10/17/19.
//  Copyright © 2019 Twilio, Inc. All rights reserved.
//

import Foundation

@objc class TwilioAccessTokenServiceFactory: NSObject {
    @objc func makeTwilioAccessTokenService() -> TwilioAccessTokenService {
        switch gCurrentAppEnvironment {
        case .twilio, .internal:
            return FirebaseTwilioAccessTokenService(
                api: TwilioVideoAppAPI(),
                appSettingsStore: AppSettingsStore(userDefaults: .standard),
                firebaseAuthManager: FirebaseAuthManager()
            )
        case .community:
            return CommunityTwilioAccessTokenService()
        @unknown default:
            fatalError()
        }
    }
}
