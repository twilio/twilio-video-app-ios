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

class EditMaxSubscriptionBitrateViewModelFactory: EditTextViewModelFactory {
    func makeEditTextViewModel() -> EditTextViewModel {
        EditMaxSubscriptionBitrateViewModel(appSettingsStore: AppSettingsStore.shared)
    }
}

class EditMaxSubscriptionBitrateViewModel: EditTextViewModel {
    let title = "Max Subscription Bitrate"
    var placeholder: String { "Server Default" }
    var text: String {
        get {
            guard let maxSubscriptionBitrate = appSettingsStore.maxSubscriptionBitrate else { return "" }
            
            return "\(maxSubscriptionBitrate)"
        }
        set {
            appSettingsStore.maxSubscriptionBitrate = Int(newValue)
        }
    }
    var keyboardType: UIKeyboardType { .numberPad }
    private let appSettingsStore: AppSettingsStoreWriting

    init(appSettingsStore: AppSettingsStoreWriting) {
        self.appSettingsStore = appSettingsStore
    }
}
