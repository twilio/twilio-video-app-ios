//
//  StubAppSettings.swift
//  Video-TwilioTests
//
//  Created by Tim Rozum on 10/17/19.
//  Copyright © 2019 Twilio, Inc. All rights reserved.
//

@testable import VideoApp

extension AppSettings {
    static func stub(
        environment: TwilioVideoAppAPIEnvironment = .production,
        topology: TwilioVideoAppAPITopology = .group
    ) -> AppSettings {
        return .init(environment: environment, topology: topology)
    }
}
