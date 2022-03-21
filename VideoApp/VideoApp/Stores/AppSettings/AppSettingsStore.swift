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
    var environment: TwilioEnvironment { get set }
    var videoCodec: VideoCodec { get set }
    var videoSize: VideoSize { get set }
    var userIdentity: String { get set }
    var isTURNMediaRelayOn: Bool { get set }
    var areInsightsEnabled: Bool { get set }
    var coreSDKLogLevel: SDKLogLevel { get set }
    var platformSDKLogLevel: SDKLogLevel { get set }
    var signalingSDKLogLevel: SDKLogLevel { get set }
    var webRTCSDKLogLevel: SDKLogLevel { get set }
    var bandwidthProfileMode: BandwidthProfileMode { get set }
    var maxSubscriptionBitrate: Int? { get set }
    var dominantSpeakerPriority: TrackPriority { get set }
    var trackSwitchOffMode: TrackSwitchOffMode { get set }
    var remoteRoomType: CreateTwilioAccessTokenResponse.RoomType? { get set }
    var clientTrackSwitchOffControl: ClientTrackSwitchOffControl { get set }
    var videoContentPreferencesMode: VideoContentPreferencesMode { get set }
    func reset()
}

class AppSettingsStore: AppSettingsStoreWriting {
    @Storage(key: makeKey("environment"), defaultValue: TwilioEnvironment.production) var environment: TwilioEnvironment
    @Storage(key: makeKey("videoCodec"), defaultValue: defaultVideoCodec) var videoCodec: VideoCodec
    @Storage(key: makeKey("videoSize"), defaultValue: .vga) var videoSize: VideoSize
    @Storage(key: makeKey("userIdentity"), defaultValue: "") var userIdentity: String
    @Storage(key: makeKey("isTURNMediaRelayOn"), defaultValue: false) var isTURNMediaRelayOn: Bool
    @Storage(key: makeKey("areInsightsEnabled"), defaultValue: true) var areInsightsEnabled: Bool
    @Storage(key: makeKey("coreSDKLogLevel"), defaultValue: SDKLogLevel.info) var coreSDKLogLevel: SDKLogLevel
    @Storage(key: makeKey("platformSDKLogLevel"), defaultValue: SDKLogLevel.info) var platformSDKLogLevel: SDKLogLevel
    @Storage(key: makeKey("signalingSDKLogLevel"), defaultValue: SDKLogLevel.error) var signalingSDKLogLevel: SDKLogLevel
    @Storage(key: makeKey("webRTCSDKLogLevel"), defaultValue: SDKLogLevel.off) var webRTCSDKLogLevel: SDKLogLevel
    @Storage(key: makeKey("bandwidthProfileMode"), defaultValue: BandwidthProfileMode.collaboration) var bandwidthProfileMode: BandwidthProfileMode
    @Storage(key: makeKey("maxSubscriptionBitrate"), defaultValue: nil) var maxSubscriptionBitrate: Int?
    @Storage(key: makeKey("dominantSpeakerPriority"), defaultValue: TrackPriority.serverDefault) var dominantSpeakerPriority: TrackPriority
    @Storage(key: makeKey("trackSwitchOffMode"), defaultValue: TrackSwitchOffMode.serverDefault) var trackSwitchOffMode: TrackSwitchOffMode
    @Storage(key: makeKey("remoteRoomType"), defaultValue: nil) var remoteRoomType: CreateTwilioAccessTokenResponse.RoomType?
    @Storage(key: makeKey("clientTrackSwitchOffControl"), defaultValue: .sdkDefault) var clientTrackSwitchOffControl: ClientTrackSwitchOffControl
    @Storage(key: makeKey("videoContentPreferencesMode"), defaultValue: .sdkDefault) var videoContentPreferencesMode: VideoContentPreferencesMode

    static var shared: AppSettingsStoreWriting = AppSettingsStore(
        notificationCenter: NotificationCenter.default,
        queue: DispatchQueue.main,
        userDefaults: UserDefaults.standard
    )
    static var appInfoStore: AppInfoStoreReading = AppInfoStoreFactory().makeAppInfoStore()
    private let notificationCenter: NotificationCenterProtocol
    private let queue: DispatchQueueProtocol
    private let userDefaults: UserDefaultsProtocol
    private static var defaultVideoCodec: VideoCodec {
        switch appInfoStore.appInfo.target {
        case .videoInternal: return .auto
        case .videoCommunity: return .vp8
        }
    }

    private static func makeKey(_ appSetting: String) -> String {
        return appSetting + "AppSetting"
    }
    
    init(
        notificationCenter: NotificationCenterProtocol,
        queue: DispatchQueueProtocol,
        userDefaults: UserDefaultsProtocol
    ) {
        self.notificationCenter = notificationCenter
        self.queue = queue
        self.userDefaults = userDefaults
    }

    func start() {
        notificationCenter.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: nil) { [weak self] _ in
            // Main queue for UI and async to prevent simultaneous access crash
            self?.queue.async { self?.postAppSettingDidChangeNotification() }
        }
    }
    
    func reset() {
        userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        postAppSettingDidChangeNotification()
    }
    
    private func postAppSettingDidChangeNotification() {
        notificationCenter.post(name: .appSettingDidChange, object: self)
    }
}
