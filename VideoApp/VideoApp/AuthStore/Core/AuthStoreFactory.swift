//
//  AuthStoreFactory.swift
//  VideoApp
//
//  Created by Tim Rozum on 10/24/19.
//  Copyright © 2019 Twilio, Inc. All rights reserved.
//

import Foundation

class AuthStoreFactory {
    func makeAuthStore() -> AuthStoreEverything {
        switch gCurrentAppEnvironment {
        case .twilio, .internal:
            return AhoyAuthStore(
                api: TwilioVideoAppAPI(),
                appSettingsStore: AppSettingsStore(userDefaults: .standard),
                firebaseAuthStore: FirebaseAuthStore()
            )
        case .community:
            return CommunityAuthStore()
        @unknown default:
            fatalError()
        }
    }
}
