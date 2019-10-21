//
//  HockeyAppIdentifierFactory.swift
//  VideoApp
//
//  Created by Tim Rozum on 10/18/19.
//  Copyright © 2019 Twilio, Inc. All rights reserved.
//

import Foundation

@objc class HockeyAppIdentifierFactory: NSObject {
    @objc func makeHockeyAppIdentifier() -> String? {
        return CredentialsStore().credentials.hockeyAppIdentifier
    }
}
