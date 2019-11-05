//
//  MockAppSettingsStore.swift
//  Video-TwilioTests
//
//  Created by Tim Rozum on 10/16/19.
//  Copyright © 2019 Twilio, Inc. All rights reserved.
//

@testable import VideoApp

class MockAppSettingsStore: AppSettingsStoreReading {
    var invokedAppSettingsGetter = false
    var invokedAppSettingsGetterCount = 0
    var stubbedAppSettings: AppSettings!
    var appSettings: AppSettings {
        invokedAppSettingsGetter = true
        invokedAppSettingsGetterCount += 1
        return stubbedAppSettings
    }
}
