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
    var roomType: CreateTwilioAccessTokenResponse.RoomType { get }
}

protocol RemoteConfigStoreWriting: RemoteConfigStoreReading {
    var roomType: CreateTwilioAccessTokenResponse.RoomType { get set }
}

class RemoteConfigStore: RemoteConfigStoreWriting {
    private let appSettingsStore: AppSettingsStoreWriting
    private let appInfoStore: AppInfoStoreReading
    
    init(appSettingsStore: AppSettingsStoreWriting, appInfoStore: AppInfoStoreReading) {
        self.appSettingsStore = appSettingsStore
        self.appInfoStore = appInfoStore
    }
    
    var roomType: CreateTwilioAccessTokenResponse.RoomType {
        get {
            guard let remoteRoomType = appSettingsStore.remoteRoomType else {
                switch appInfoStore.appInfo.target {
                case .videoCommunity:
                    return .peerToPeer
                case .videoInternal:
                    return .group
                }
            }
            
            return remoteRoomType
        }
        set {
            guard newValue != appSettingsStore.remoteRoomType else { return }

            appSettingsStore.videoCodec = .auto
            appSettingsStore.remoteRoomType = newValue
        }
    }
}
