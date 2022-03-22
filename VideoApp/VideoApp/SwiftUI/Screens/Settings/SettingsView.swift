//
//  Copyright (C) 2022 Twilio, Inc.
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

import SwiftUI

struct SettingsView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let viewModel = GeneralSettingsViewModel(
            appInfoStore: AppInfoStoreFactory().makeAppInfoStore(),
            appSettingsStore: AppSettingsStore.shared,
            authStore: AuthStore.shared
        )
        let settingsController = SettingsViewControllerFactory().makeSettingsViewController(viewModel: viewModel)

        let navigationController = UINavigationController()
        navigationController.viewControllers = [settingsController]

        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {

    }
}
