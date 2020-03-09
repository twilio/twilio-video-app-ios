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
    @objc static var appSettingsStoreDidChangeNotificationName: String { Notification.Name.appSettingDidChange.rawValue }
    @objc static var enableVP8Simulcast: Bool { AppSettingsStore.shared.videoCodec == .vp8Simulcast }
    @objc static var forceTURNMediaRelay: Bool { AppSettingsStore.shared.isTURNMediaRelayOn }
    @objc static var isGroupTopology: Bool { AppSettingsStore.shared.topology == .group }
    @objc static var userDisplayName: String {
        UserStore(appSettingsStore: AppSettingsStore.shared, authStore: AuthStore.shared).user.displayName
    }
    @objc static var roomNameFromDeepLink: String? {
        guard let deepLink = DeepLinkStore.shared.consumeDeepLink() else { return nil }
        
        switch deepLink {
        case let .room(roomName): return roomName
        }
    }

    @objc static func fetchTwilioAccessToken(roomName: String, completion: @escaping (String?, String?) -> Void) {
        AuthStore.shared.fetchTwilioAccessToken(roomName: roomName) { completion($0, $1?.message) }
    }

    @objc static func prepareForShowSettingsSegue(_ segue: UIStoryboardSegue) {
        let navigationController = segue.destination as! UINavigationController
        let settingsViewController = navigationController.viewControllers.first as! SettingsViewController
        settingsViewController.viewModel = GeneralSettingsViewModel(
            appInfoStore: AppInfoStoreFactory().makeAppInfoStore(),
            appSettingsStore: AppSettingsStore.shared,
            authStore: AuthStore.shared,
            selectVideoCodecViewModelFactory: SelectVideoCodecViewModelFactory()
        )
    }
}
