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
        [
            .init(
                rows: [
                    .optionList(
                        title: "Environment",
                        selectedOption: appSettingsStore.environment.title,
                        viewModelFactory: selectEnvironmentViewModelFactory
                    ),
                    .editableText(
                        title: "User Identity",
                        text: userStore.user.displayName,
                        viewModelFactory: editIdentityViewModalFactory
                    ),
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
    }
    private let appSettingsStore: AppSettingsStoreWriting
    private let userStore: UserStoreReading
    private let crashReportStore: CrashReportStoreWriting
    private let editIdentityViewModalFactory: EditTextViewModelFactory
    private let selectEnvironmentViewModelFactory: SelectEnvironmentViewModelFactory
    private let developerSettingsViewControllerFactory: DeveloperSettingsViewControllerFactory
    private let sdkLogLevelSettingsViewControllerFactory: SDKLogLevelSettingsViewControllerFactory
    
    init(appSettingsStore: AppSettingsStoreWriting,
         userStore: UserStoreReading,
         crashReportStore: CrashReportStoreWriting,
         editIdentityViewModalFactory: EditTextViewModelFactory,
         selectEnvironmentViewModelFactory: SelectEnvironmentViewModelFactory,
         developerSettingsViewControllerFactory: DeveloperSettingsViewControllerFactory,
         sdkLogLevelSettingsViewControllerFactory: SDKLogLevelSettingsViewControllerFactory
    ) {
        self.appSettingsStore = appSettingsStore
        self.userStore = userStore
        self.crashReportStore = crashReportStore
        self.editIdentityViewModalFactory = editIdentityViewModalFactory
        self.selectEnvironmentViewModelFactory = selectEnvironmentViewModelFactory
        self.developerSettingsViewControllerFactory = developerSettingsViewControllerFactory
        self.sdkLogLevelSettingsViewControllerFactory = sdkLogLevelSettingsViewControllerFactory
    }
}
