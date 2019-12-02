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

class SelectVideoCodecViewModel: SelectOptionViewModel {
    let title = "Video Codec"
    let options = VideoCodec.allCases.map { $0.title }
    var selectedIndex: Int {
        get { VideoCodec.allCases.firstIndex(of: appSettingsStore.videoCodec) ?? 0 }
        set { appSettingsStore.videoCodec = VideoCodec.allCases[newValue] }
    }
    private let appSettingsStore: AppSettingsStoreWriting
    
    init(appSettingsStore: AppSettingsStoreWriting) {
        self.appSettingsStore = appSettingsStore
    }
}
