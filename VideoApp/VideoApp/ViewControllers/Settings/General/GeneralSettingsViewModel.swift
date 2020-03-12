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
        var sections = [
            SettingsViewModelSection(
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
            SettingsViewModelSection(
                rows: [
                    .optionList(
                        title: "Video Codec",
                        selectedOption: appSettingsStore.videoCodec.title,
                        viewModelFactory: selectVideoCodecViewModelFactory
                    ),
                    .toggle(title: "TURN Media Relay",
                        isOn: appSettingsStore.isTURNMediaRelayOn,
                        updateHandler: { self.appSettingsStore.isTURNMediaRelayOn = $0 }
                    )
                ]
            )
        ]

        if appInfoStore.appInfo.target == .videoInternal {
            sections.append(
                SettingsViewModelSection(
                    rows: [
                        .push(
                            title: "Advanced",
                            viewControllerFactory: AdvancedSettingsViewControllerFactory()
                        )
                    ]
                )
            )
        }

        sections.append(
            SettingsViewModelSection(
                rows: [
                    .destructiveButton(
                        title: "Sign Out",
                        tapHandler: { self.authStore.signOut() }
                    )
                ]
            )
        )
        
        return sections
    }
    private let appInfoStore: AppInfoStoreReading
    private let appSettingsStore: AppSettingsStoreWriting
    private let authStore: AuthStoreWriting
    private let selectVideoCodecViewModelFactory: SelectOptionViewModelFactory

    init(
        appInfoStore: AppInfoStoreReading,
        appSettingsStore: AppSettingsStoreWriting,
        authStore: AuthStoreWriting,
        selectVideoCodecViewModelFactory: SelectOptionViewModelFactory
    ) {
        self.appInfoStore = appInfoStore
        self.appSettingsStore = appSettingsStore
        self.authStore = authStore
        self.selectVideoCodecViewModelFactory = selectVideoCodecViewModelFactory
    }
}
