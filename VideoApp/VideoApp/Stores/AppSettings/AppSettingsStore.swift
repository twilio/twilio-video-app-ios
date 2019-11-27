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

protocol AppSettingsStoreWriting: AnyObject {
    var apiEnvironment: APIEnvironment { get set }
    var videoCodec: VideoCodec { get set }
    var topology: Topology { get set }
    var userIdentity: String { get set }
    var isTURNMediaRelayOn: Bool { get set }
}

class AppSettingsStore: AppSettingsStoreWriting {
    private enum Keys {
        static let apiEnvironment = "apiEnvironmentSetting"
        static let videoCodec = "videoCodecSetting"
        static let topology = "topologySetting"
        static let userIdentity = "userIdentitySetting"
        static let isTURNMediaRelayOn = "isTURNMediaRelayOnSetting"
    }

    var apiEnvironment: APIEnvironment {
        get {
            guard let rawAPIEnvironment = userDefaults.string(forKey: Keys.apiEnvironment), let apiEnvironment = APIEnvironment(rawValue: rawAPIEnvironment) else {
                return .production
            }
            
            return apiEnvironment
        }
        set { userDefaults.setValue(newValue.rawValue, forKey: Keys.apiEnvironment) }
    }
    var videoCodec: VideoCodec {
        get {
            guard let rawVideoCodec = userDefaults.string(forKey: Keys.videoCodec), let videoCodec = VideoCodec(rawValue: rawVideoCodec) else {
                return .h264
            }
            
            return videoCodec
        }
        set { userDefaults.setValue(newValue.rawValue, forKey: Keys.videoCodec) }
    }
    var topology: Topology {
        get {
            guard let rawTopology = userDefaults.string(forKey: Keys.topology), let topology = Topology(rawValue: rawTopology) else {
                return .group
            }
            
            return topology
        }
        set { userDefaults.setValue(newValue.rawValue, forKey: Keys.topology) }
    }
    var userIdentity: String {
        get { userDefaults.string(forKey: Keys.userIdentity) ?? "" }
        set { userDefaults.setValue(newValue, forKey: Keys.userIdentity) }
    }
    var isTURNMediaRelayOn: Bool {
        get { userDefaults.bool(forKey: Keys.isTURNMediaRelayOn) }
        set { userDefaults.setValue(newValue, forKey: Keys.isTURNMediaRelayOn) }
    }
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
}
