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
        
        if appInfoStore.appInfo.target == .videoInternal {
            sections.append(
                .init(
                    rows: [
                        .optionList(
                            title: "Environment",
                            selectedOption: appSettingsStore.environment.title,
                            viewModelFactory: selectEnvironmentViewModelFactory
                        )
                    ]
                )
            )
        }

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
                            title: "Topology",
                            selectedOption: appSettingsStore.topology.title,
                            viewModelFactory: selectTopologyViewModelFactory
                        ),
                        .optionList(
                            title: "Video Codec",
                            selectedOption: appSettingsStore.videoCodec.title,
                            viewModelFactory: selectVideoCodecViewModelFactory
                        ),
                        .toggle(
                            title: "TURN Media Relay",
                            isOn: appSettingsStore.isTURNMediaRelayOn,
                            updateHandler: { self.appSettingsStore.isTURNMediaRelayOn = $0 }
                        ),
                        .push(
                            title: "Bandwidth Profile",
                            viewControllerFactory: bandwidthProfileSettingsViewControllerFactory
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
        
        return sections
    }
    private let appInfoStore: AppInfoStoreReading
    private let appSettingsStore: AppSettingsStoreWriting
    private let userStore: UserStoreReading
    private let editIdentityViewModalFactory: EditTextViewModelFactory
    private let selectTopologyViewModelFactory: SelectOptionViewModelFactory
    private let selectEnvironmentViewModelFactory: SelectEnvironmentViewModelFactory
    private let developerSettingsViewControllerFactory: DeveloperSettingsViewControllerFactory
    private let sdkLogLevelSettingsViewControllerFactory: SDKLogLevelSettingsViewControllerFactory
    private let selectVideoCodecViewModelFactory: SelectOptionViewModelFactory
    private let bandwidthProfileSettingsViewControllerFactory: BandwidthProfileSettingsViewControllerFactory

    init(
        appInfoStore: AppInfoStoreReading,
        appSettingsStore: AppSettingsStoreWriting,
        userStore: UserStoreReading,
        editIdentityViewModalFactory: EditTextViewModelFactory,
        selectTopologyViewModelFactory: SelectOptionViewModelFactory,
        selectEnvironmentViewModelFactory: SelectEnvironmentViewModelFactory,
        developerSettingsViewControllerFactory: DeveloperSettingsViewControllerFactory,
        sdkLogLevelSettingsViewControllerFactory: SDKLogLevelSettingsViewControllerFactory,
        selectVideoCodecViewModelFactory: SelectOptionViewModelFactory,
        bandwidthProfileSettingsViewControllerFactory: BandwidthProfileSettingsViewControllerFactory
    ) {
        self.appInfoStore = appInfoStore
        self.appSettingsStore = appSettingsStore
        self.userStore = userStore
        self.editIdentityViewModalFactory = editIdentityViewModalFactory
        self.selectTopologyViewModelFactory = selectTopologyViewModelFactory
        self.selectEnvironmentViewModelFactory = selectEnvironmentViewModelFactory
        self.developerSettingsViewControllerFactory = developerSettingsViewControllerFactory
        self.sdkLogLevelSettingsViewControllerFactory = sdkLogLevelSettingsViewControllerFactory
        self.selectVideoCodecViewModelFactory = selectVideoCodecViewModelFactory
        self.bandwidthProfileSettingsViewControllerFactory = bandwidthProfileSettingsViewControllerFactory
    }
}
