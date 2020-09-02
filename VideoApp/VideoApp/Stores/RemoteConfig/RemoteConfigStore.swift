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

protocol RemoteConfigStoreReading: AnyObject {
    var roomType: CommunityCreateTwilioAccessTokenResponse.RoomType { get }
}

protocol RemoteConfigStoreWriting: RemoteConfigStoreReading {
    var roomType: CommunityCreateTwilioAccessTokenResponse.RoomType { get set }
}

class RemoteConfigStore: RemoteConfigStoreWriting {
    private let appSettingsStore: AppSettingsStoreWriting
    
    init(appSettingsStore: AppSettingsStoreWriting) {
        self.appSettingsStore = appSettingsStore
    }
    
    var roomType: CommunityCreateTwilioAccessTokenResponse.RoomType {
        get {
            appSettingsStore.remoteRoomType ?? .peerToPeer
        }
        set {
            guard newValue != appSettingsStore.remoteRoomType else { return }
            
            switch newValue {
            case .group, .groupSmall, .unknown:
                appSettingsStore.videoCodec = .vp8SimulcastVGA
            case .peerToPeer:
                appSettingsStore.videoCodec = .vp8
            }

            appSettingsStore.remoteRoomType = newValue
        }
    }
}
