//
//  TwilioVideoAppAPIProtocol.swift
//  VideoApp
//
//  Created by Tim Rozum on 10/16/19.
//  Copyright © 2019 Twilio, Inc. All rights reserved.
//

import Foundation

protocol TwilioVideoAppAPIProtocol {
    func retrieveAccessToken(
        forIdentity identity: String,
        roomName: String,
        authToken: String,
        environment: TwilioVideoAppAPIEnvironment,
        topology: TwilioVideoAppAPITopology,
        completionBlock: @escaping (String?, Error?) -> Void
    )
}

extension TwilioVideoAppAPI: TwilioVideoAppAPIProtocol { }
