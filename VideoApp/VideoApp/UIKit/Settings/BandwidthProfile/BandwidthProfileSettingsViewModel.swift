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

class BandwidthProfileSettingsViewModel: SettingsViewModel {
    let title = "Bandwidth Profile"
    var sections: [SettingsViewModelSection] {
        let editMaxSubscriptionBitrateViewModel = editMaxSubscriptionBitrateViewModelFactory.makeEditTextViewModel()
        
        return [
            .init(
                rows: [
                    .optionList(
                        title: "Mode",
                        selectedOption: appSettingsStore.bandwidthProfileMode.title,
                        viewModelFactory: selectBandwidthProfileModeViewModelFactory
                    ),
                    .editableText(
                        title: editMaxSubscriptionBitrateViewModel.title,
                        text: editMaxSubscriptionBitrateViewModel.text.nilIfEmpty ?? editMaxSubscriptionBitrateViewModel.placeholder,
                        viewModelFactory: editMaxSubscriptionBitrateViewModelFactory
                    ),
                    .optionList(
                        title: "Dominant Speaker Priority",
                        selectedOption: appSettingsStore.dominantSpeakerPriority.title,
                        viewModelFactory: selectDominantSpeakerPriorityViewModelFactory
                    ),
                    .optionList(
                        title: "Track Switch Off Mode",
                        selectedOption: appSettingsStore.trackSwitchOffMode.title,
                        viewModelFactory: selectTrackSwitchOffModeViewModelFactory
                    ),
                    .optionList(
                        title: "Client Track Switch Off Control",
                        selectedOption: appSettingsStore.clientTrackSwitchOffControl.title,
                        viewModelFactory: selectClientTrackSwitchOffControlViewModelFactory
                    ),
                    .optionList(
                        title: "Video Content Preferences Mode",
                        selectedOption: appSettingsStore.videoContentPreferencesMode.title,
                        viewModelFactory: selectVideoContentPreferencesModeViewControllerFactory
                    )
                ]
            )
        ]
    }
    private let appSettingsStore: AppSettingsStoreWriting
    private let selectBandwidthProfileModeViewModelFactory: SelectBandwidthProfileModeViewModelFactory
    private let editMaxSubscriptionBitrateViewModelFactory: EditMaxSubscriptionBitrateViewModelFactory
    private let selectDominantSpeakerPriorityViewModelFactory: SelectDominantSpeakerPriorityViewModelFactory
    private let selectClientTrackSwitchOffControlViewModelFactory: SelectClientTrackSwitchOffControlViewModelFactory
    private let selectTrackSwitchOffModeViewModelFactory: SelectTrackSwitchOffModeViewModelFactory
    private let selectVideoContentPreferencesModeViewControllerFactory: SelectVideoContentPreferencesViewModelFactory
    
    init(
        appSettingsStore: AppSettingsStoreWriting,
        selectBandwidthProfileModeViewModelFactory: SelectBandwidthProfileModeViewModelFactory,
        editMaxSubscriptionBitrateViewModelFactory: EditMaxSubscriptionBitrateViewModelFactory,
        selectDominantSpeakerPriorityViewModelFactory: SelectDominantSpeakerPriorityViewModelFactory,
        selectClientTrackSwitchOffControlViewModelFactory: SelectClientTrackSwitchOffControlViewModelFactory,
        selectTrackSwitchOffModeViewModelFactory: SelectTrackSwitchOffModeViewModelFactory,
        selectVideoContentPreferencesModeViewControllerFactory: SelectVideoContentPreferencesViewModelFactory
    ) {
        self.appSettingsStore = appSettingsStore
        self.selectBandwidthProfileModeViewModelFactory = selectBandwidthProfileModeViewModelFactory
        self.editMaxSubscriptionBitrateViewModelFactory = editMaxSubscriptionBitrateViewModelFactory
        self.selectDominantSpeakerPriorityViewModelFactory = selectDominantSpeakerPriorityViewModelFactory
        self.selectClientTrackSwitchOffControlViewModelFactory = selectClientTrackSwitchOffControlViewModelFactory
        self.selectTrackSwitchOffModeViewModelFactory = selectTrackSwitchOffModeViewModelFactory
        self.selectVideoContentPreferencesModeViewControllerFactory = selectVideoContentPreferencesModeViewControllerFactory
    }
}
