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

protocol AppSettingsStoreWriting: LaunchStore {
    var apiEnvironment: APIEnvironment { get set }
    var videoCodec: VideoCodec { get set }
    var topology: Topology { get set }
    var userIdentity: String { get set }
    var isTURNMediaRelayOn: Bool { get set }
    var coreSDKLogLevel: SDKLogLevel { get set }
    var platformSDKLogLevel: SDKLogLevel { get set }
    var signalingSDKLogLevel: SDKLogLevel { get set }
    var webRTCSDKLogLevel: SDKLogLevel { get set }
}

class AppSettingsStore: AppSettingsStoreWriting {
    @Storage(key: makeKey("apiEnvironment"), defaultValue: APIEnvironment.production) var apiEnvironment: APIEnvironment
    @Storage(key: makeKey("videoCodec"), defaultValue: VideoCodec.h264) var videoCodec: VideoCodec
    @Storage(key: makeKey("topology"), defaultValue: Topology.group) var topology: Topology
    @Storage(key: makeKey("userIdentity"), defaultValue: "") var userIdentity: String
    @Storage(key: makeKey("isTURNMediaRelayOn"), defaultValue: false) var isTURNMediaRelayOn: Bool
    @Storage(key: makeKey("coreSDKLogLevel"), defaultValue: SDKLogLevel.info) var coreSDKLogLevel: SDKLogLevel
    @Storage(key: makeKey("platformSDKLogLevel"), defaultValue: SDKLogLevel.info) var platformSDKLogLevel: SDKLogLevel
    @Storage(key: makeKey("signalingSDKLogLevel"), defaultValue: SDKLogLevel.error) var signalingSDKLogLevel: SDKLogLevel
    @Storage(key: makeKey("webRTCSDKLogLevel"), defaultValue: SDKLogLevel.off) var webRTCSDKLogLevel: SDKLogLevel

    static var shared: AppSettingsStoreWriting = AppSettingsStore(notificationCenter: NotificationCenter.default, queue: DispatchQueue.main)
    private let notificationCenter: NotificationCenterProtocol
    private let queue: DispatchQueueProtocol
    
    private static func makeKey(_ appSetting: String) -> String {
        return appSetting + "AppSetting"
    }
    
    init(notificationCenter: NotificationCenterProtocol, queue: DispatchQueueProtocol) {
        self.notificationCenter = notificationCenter
        self.queue = queue
    }

    func start() {
        notificationCenter.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: nil) { [weak self] _ in
            // Main queue for UI and async to prevent simultaneous access crash
            self?.queue.async { self?.notificationCenter.post(name: .appSettingDidChange, object: self) }
        }
    }
}
