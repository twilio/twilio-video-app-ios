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

class SDKLogLevelSettingsViewControllerFactory: ViewControllerFactory {
    func makeViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "SettingsController") as! SettingsViewController
        viewController.viewModel = SDKLogLevelSettingsViewModel(
            appSettingsStore: AppSettingsStore.shared,
            selectCoreSDKLogLevelViewModelFactory: SelectCoreSDKLogLevelViewModelFactory(),
            selectPlatformSDKLogLevelViewModelFactory: SelectPlatformSDKLogLevelViewModelFactory(),
            selectSignalingSDKLogLevelViewModelFactory: SelectSignalingSDKLogLevelViewModelFactory(),
            selectWebRTCSDKLogLevelViewModelFactory: SelectWebRTCSDKLogLevelViewModelFactory()
        )
        return viewController
    }
}
