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

class AdvancedSettingsViewModel: SettingsViewModel {
    let title = "Advanced"
    var sections: [SettingsViewModelSection] {
        var sections: [SettingsViewModelSection] = []

        sections.append(
            contentsOf: [
                .init(
                    rows: [
                        .editableText(
                            title: "User Identity",
                            text: userStore.user.displayName,
                            viewModelFactory: editIdentityViewModalFactory
                        )
                    ]
                ),
                .init(
                    rows: [
                        .optionList(
                            title: "Video Codec",
                            selectedOption: appSettingsStore.videoCodec.title,
                            viewModelFactory: selectVideoCodecViewModelFactory
                        ),
                        .optionList(
                            title: "Video Size",
                            selectedOption: appSettingsStore.videoSize.title,
                            viewModelFactory: selectVideoSizeViewModelFactory
                        ),
                        .toggle(
                            title: "TURN Media Relay",
                            isOn: appSettingsStore.isTURNMediaRelayOn,
                            updateHandler: { self.appSettingsStore.isTURNMediaRelayOn = $0 }
                        ),
                        .push(
                            title: "Bandwidth Profile",
                            viewControllerFactory: bandwidthProfileSettingsViewControllerFactory
                        ),
                        .toggle(
                            title: "Insights",
                            isOn: appSettingsStore.areInsightsEnabled,
                            updateHandler: { self.appSettingsStore.areInsightsEnabled = $0 }
                        )
                    ]
                ),
                .init(
                    rows: [
                        .push(
                            title: "SDK Log Levels",
                            viewControllerFactory: sdkLogLevelSettingsViewControllerFactory
                        )
                    ]
                ),
                .init(
                    rows: [
                        .push(
                            title: "Developer",
                            viewControllerFactory: developerSettingsViewControllerFactory
                        )
                    ]
                )
            ]
        )

        if appInfoStore.appInfo.target == .videoInternal {
            sections.append(
                .init(
                    rows: [
                        .push(
                            title: "Internal",
                            viewControllerFactory: internalSettingsViewControllerFactory
                        )
                    ]
                )
            )
        }

        return sections
    }
    private let appInfoStore: AppInfoStoreReading
    private let appSettingsStore: AppSettingsStoreWriting
    private let userStore: UserStoreReading
    private let editIdentityViewModalFactory: EditTextViewModelFactory
    private let developerSettingsViewControllerFactory: DeveloperSettingsViewControllerFactory
    private let sdkLogLevelSettingsViewControllerFactory: SDKLogLevelSettingsViewControllerFactory
    private let selectVideoCodecViewModelFactory: SelectOptionViewModelFactory
    private let selectVideoSizeViewModelFactory: SelectOptionViewModelFactory
    private let bandwidthProfileSettingsViewControllerFactory: BandwidthProfileSettingsViewControllerFactory
    private let internalSettingsViewControllerFactory: InternalSettingsViewControllerFactory

    init(
        appInfoStore: AppInfoStoreReading,
        appSettingsStore: AppSettingsStoreWriting,
        userStore: UserStoreReading,
        editIdentityViewModalFactory: EditTextViewModelFactory,
        developerSettingsViewControllerFactory: DeveloperSettingsViewControllerFactory,
        sdkLogLevelSettingsViewControllerFactory: SDKLogLevelSettingsViewControllerFactory,
        selectVideoCodecViewModelFactory: SelectOptionViewModelFactory,
        selectVideoSizeViewModelFactory: SelectOptionViewModelFactory,
        bandwidthProfileSettingsViewControllerFactory: BandwidthProfileSettingsViewControllerFactory,
        internalSettingsViewControllerFactory: InternalSettingsViewControllerFactory
    ) {
        self.appInfoStore = appInfoStore
        self.appSettingsStore = appSettingsStore
        self.userStore = userStore
        self.editIdentityViewModalFactory = editIdentityViewModalFactory
        self.developerSettingsViewControllerFactory = developerSettingsViewControllerFactory
        self.sdkLogLevelSettingsViewControllerFactory = sdkLogLevelSettingsViewControllerFactory
        self.selectVideoCodecViewModelFactory = selectVideoCodecViewModelFactory
        self.selectVideoSizeViewModelFactory = selectVideoSizeViewModelFactory
        self.bandwidthProfileSettingsViewControllerFactory = bandwidthProfileSettingsViewControllerFactory
        self.internalSettingsViewControllerFactory = internalSettingsViewControllerFactory
    }
}
