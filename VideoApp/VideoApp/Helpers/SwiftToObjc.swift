//
//  Copyright (C) 2019 Twilio, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

@objc class SwiftToObjc: NSObject {
    @objc static var enableVP8Simulcast: Bool { AppSettingsStore(userDefaults: .standard).videoCodec == .vp8Simulcast }
    @objc static var forceTURNMediaRelay: Bool { AppSettingsStore(userDefaults: .standard).isTURNMediaRelayOn }
    @objc static var userDisplayName: String {
        UserStore(appSettingsStore: AppSettingsStore(userDefaults: .standard), authStore: AuthStore.shared).user.displayName
    }

    @objc static func prepareForShowSettingsSegue(_ segue: UIStoryboardSegue) {
        let navigationController = segue.destination as! UINavigationController
        let settingsViewController = navigationController.viewControllers.first as! SettingsViewController
        settingsViewController.viewModel = GeneralSettingsViewModel(
            appInfoStore: AppInfoStore(bundle: Bundle.main),
            appSettingsStore: AppSettingsStore(userDefaults: .standard),
            authStore: AuthStore.shared,
            selectTopologyViewModelFactory: SelectTopologyViewModelFactory(),
            selectVideoCodecViewModelFactory: SelectVideoCodecViewModelFactory()
        )
    }
}
