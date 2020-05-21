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

class RenderDimensionsSettingsViewModel: SettingsViewModel {
    let title = "Render Dimensions"
    var sections: [SettingsViewModelSection] {
        [
            .init(
                rows: [
                    .optionList(
                        title: "Low",
                        selectedOption: appSettingsStore.lowRenderDimensions.title,
                        viewModelFactory: selectLowRenderDimensionsViewModelFactory
                    ),
                    .optionList(
                        title: "Standard",
                        selectedOption: appSettingsStore.standardRenderDimensions.title,
                        viewModelFactory: selectStandardRenderDimensionsViewModelFactory
                    ),
                    .optionList(
                        title: "High",
                        selectedOption: appSettingsStore.highRenderDimensions.title,
                        viewModelFactory: selectHighRenderDimensionsViewModelFactory
                    ),
                ]
            )
        ]
    }
    private let appSettingsStore: AppSettingsStoreWriting
    private let selectLowRenderDimensionsViewModelFactory: SelectLowRenderDimensionsViewModelFactory
    private let selectStandardRenderDimensionsViewModelFactory: SelectStandardRenderDimensionsViewModelFactory
    private let selectHighRenderDimensionsViewModelFactory: SelectHighRenderDimensionsViewModelFactory
    
    init(
        appSettingsStore: AppSettingsStoreWriting,
        selectLowRenderDimensionsViewModelFactory: SelectLowRenderDimensionsViewModelFactory,
        selectStandardRenderDimensionsViewModelFactory: SelectStandardRenderDimensionsViewModelFactory,
        selectHighRenderDimensionsViewModelFactory: SelectHighRenderDimensionsViewModelFactory
    ) {
        self.appSettingsStore = appSettingsStore
        self.selectLowRenderDimensionsViewModelFactory = selectLowRenderDimensionsViewModelFactory
        self.selectStandardRenderDimensionsViewModelFactory = selectStandardRenderDimensionsViewModelFactory
        self.selectHighRenderDimensionsViewModelFactory = selectHighRenderDimensionsViewModelFactory
    }
}
