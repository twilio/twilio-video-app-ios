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

class SelectSettingViewModel<T: SettingOptions>: SelectOptionViewModel {
    let title: String
    let options = T.allCases.map { $0.title }
    var selectedIndex: Int {
        get { T.allCases.firstIndex(of: appSettingsStore[keyPath: keyPath]) as! Int }
        set { appSettingsStore[keyPath: keyPath] = T.allCases[newValue as! T.AllCases.Index] }
    }

    private let keyPath: ReferenceWritableKeyPath<AppSettingsStoreWriting, T>
    private let appSettingsStore: AppSettingsStoreWriting
    
    init(
        title: String,
        keyPath: ReferenceWritableKeyPath<AppSettingsStoreWriting, T>,
        appSettingsStore: AppSettingsStoreWriting
    ) {
        self.title = title
        self.keyPath = keyPath
        self.appSettingsStore = appSettingsStore
    }
}
