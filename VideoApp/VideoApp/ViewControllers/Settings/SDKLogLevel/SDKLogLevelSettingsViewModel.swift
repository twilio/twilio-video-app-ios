//
//  Copyright (C) 2020 Twilio, Inc.
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

class SDKLogLevelSettingsViewModel: SettingsViewModel {
    let title = "SDK Log Levels"
    var sections: [SettingsViewModelSection] {
        [
            .init(
                rows: [
                    .optionList(
                        title: "Core",
                        selectedOption: appSettingsStore.coreSDKLogLevel.title,
                        viewModelFactory: selectCoreSDKLogLevelViewModelFactory
                    ),
                    .optionList(
                        title: "Platform",
                        selectedOption: appSettingsStore.platformSDKLogLevel.title,
                        viewModelFactory: selectPlatformSDKLogLevelViewModelFactory
                    ),
                    .optionList(
                        title: "Signaling",
                        selectedOption: appSettingsStore.signalingSDKLogLevel.title,
                        viewModelFactory: selectSignalingSDKLogLevelViewModelFactory
                    ),
                    .optionList(
                        title: "WebRTC",
                        selectedOption: appSettingsStore.webRTCSDKLogLevel.title,
                        viewModelFactory: selectWebRTCSDKLogLevelViewModelFactory
                    )
                ]
            )
        ]
    }
    private let appSettingsStore: AppSettingsStoreWriting
    private let selectCoreSDKLogLevelViewModelFactory: SelectCoreSDKLogLevelViewModelFactory
    private let selectPlatformSDKLogLevelViewModelFactory: SelectPlatformSDKLogLevelViewModelFactory
    private let selectSignalingSDKLogLevelViewModelFactory: SelectSignalingSDKLogLevelViewModelFactory
    private let selectWebRTCSDKLogLevelViewModelFactory: SelectWebRTCSDKLogLevelViewModelFactory

    init(appSettingsStore: AppSettingsStoreWriting,
         selectCoreSDKLogLevelViewModelFactory: SelectCoreSDKLogLevelViewModelFactory,
         selectPlatformSDKLogLevelViewModelFactory: SelectPlatformSDKLogLevelViewModelFactory,
         selectSignalingSDKLogLevelViewModelFactory: SelectSignalingSDKLogLevelViewModelFactory,
         selectWebRTCSDKLogLevelViewModelFactory: SelectWebRTCSDKLogLevelViewModelFactory
    ) {
        self.appSettingsStore = appSettingsStore
        self.selectCoreSDKLogLevelViewModelFactory = selectCoreSDKLogLevelViewModelFactory
        self.selectPlatformSDKLogLevelViewModelFactory = selectPlatformSDKLogLevelViewModelFactory
        self.selectSignalingSDKLogLevelViewModelFactory = selectSignalingSDKLogLevelViewModelFactory
        self.selectWebRTCSDKLogLevelViewModelFactory = selectWebRTCSDKLogLevelViewModelFactory
    }
}
