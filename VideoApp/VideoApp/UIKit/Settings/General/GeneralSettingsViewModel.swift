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

import TwilioVideo

class GeneralSettingsViewModel: SettingsViewModel {
    let title = "Settings"
    var sections: [SettingsViewModelSection] {
        [
            .init(
                rows: [
                    .info(
                        title: "App Version",
                        detail: "\(appInfoStore.appInfo.version) (\(appInfoStore.appInfo.build))"
                    ),
                    .info(
                        title: "SDK Version",
                        detail: TwilioVideoSDK.sdkVersion()
                    )
                ]
            ),
            .init(
                rows: [
                    .push(
                        title: "Advanced",
                        viewControllerFactory: AdvancedSettingsViewControllerFactory()
                    )
                ]
            ),
            .init(
                rows: [
                    .destructiveButton(
                        title: "Sign Out",
                        tapHandler: { self.authStore.signOut() }
                    )
                ]
            )
        ]
    }
    private let appInfoStore: AppInfoStoreReading
    private let appSettingsStore: AppSettingsStoreWriting
    private let authStore: AuthStoreWriting

    init(
        appInfoStore: AppInfoStoreReading,
        appSettingsStore: AppSettingsStoreWriting,
        authStore: AuthStoreWriting
    ) {
        self.appInfoStore = appInfoStore
        self.appSettingsStore = appSettingsStore
        self.authStore = authStore
    }
}
