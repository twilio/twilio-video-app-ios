//
//  AppSettingsStore.swift
//  VideoApp
//
//  Created by Tim Rozum on 10/16/19.
//  Copyright © 2019 Twilio, Inc. All rights reserved.
//

import Foundation

protocol AppSettingsStoreReading {
    var appSettings: AppSettings { get }
}

class AppSettingsStore: AppSettingsStoreReading {
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    var appSettings: AppSettings {
        let environment = TwilioVideoAppAPIEnvironment(rawValue: userDefaults.string(forKey: kSettingsSelectedEnvironmentKey)!)
        let topology = TwilioVideoAppAPITopology(rawValue: userDefaults.string(forKey: kSettingsSelectedTopologyKey)!)
        
        return AppSettings(environment: environment, topology: topology)
    }
}
