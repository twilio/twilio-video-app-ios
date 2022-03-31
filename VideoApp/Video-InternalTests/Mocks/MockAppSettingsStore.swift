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

@testable import VideoApp

class MockAppSettingsStore: AppSettingsStoreWriting {

    var invokedEnvironmentSetter = false
    var invokedEnvironmentSetterCount = 0
    var invokedEnvironment: TwilioEnvironment?
    var invokedEnvironmentList = [TwilioEnvironment]()
    var invokedEnvironmentGetter = false
    var invokedEnvironmentGetterCount = 0
    var stubbedEnvironment: TwilioEnvironment!

    var environment: TwilioEnvironment {
        set {
            invokedEnvironmentSetter = true
            invokedEnvironmentSetterCount += 1
            invokedEnvironment = newValue
            invokedEnvironmentList.append(newValue)
        }
        get {
            invokedEnvironmentGetter = true
            invokedEnvironmentGetterCount += 1
            return stubbedEnvironment
        }
    }

    var invokedVideoCodecSetter = false
    var invokedVideoCodecSetterCount = 0
    var invokedVideoCodec: VideoCodec?
    var invokedVideoCodecList = [VideoCodec]()
    var invokedVideoCodecGetter = false
    var invokedVideoCodecGetterCount = 0
    var stubbedVideoCodec: VideoCodec!

    var videoCodec: VideoCodec {
        set {
            invokedVideoCodecSetter = true
            invokedVideoCodecSetterCount += 1
            invokedVideoCodec = newValue
            invokedVideoCodecList.append(newValue)
        }
        get {
            invokedVideoCodecGetter = true
            invokedVideoCodecGetterCount += 1
            return stubbedVideoCodec
        }
    }

    var invokedVideoSizeSetter = false
    var invokedVideoSizeSetterCount = 0
    var invokedVideoSize: VideoSize?
    var invokedVideoSizeList = [VideoSize]()
    var invokedVideoSizeGetter = false
    var invokedVideoSizeGetterCount = 0
    var stubbedVideoSize: VideoSize!

    var videoSize: VideoSize {
        set {
            invokedVideoSizeSetter = true
            invokedVideoSizeSetterCount += 1
            invokedVideoSize = newValue
            invokedVideoSizeList.append(newValue)
        }
        get {
            invokedVideoSizeGetter = true
            invokedVideoSizeGetterCount += 1
            return stubbedVideoSize
        }
    }

    var invokedUserIdentitySetter = false
    var invokedUserIdentitySetterCount = 0
    var invokedUserIdentity: String?
    var invokedUserIdentityList = [String]()
    var invokedUserIdentityGetter = false
    var invokedUserIdentityGetterCount = 0
    var stubbedUserIdentity: String! = ""

    var userIdentity: String {
        set {
            invokedUserIdentitySetter = true
            invokedUserIdentitySetterCount += 1
            invokedUserIdentity = newValue
            invokedUserIdentityList.append(newValue)
        }
        get {
            invokedUserIdentityGetter = true
            invokedUserIdentityGetterCount += 1
            return stubbedUserIdentity
        }
    }

    var invokedIsTURNMediaRelayOnSetter = false
    var invokedIsTURNMediaRelayOnSetterCount = 0
    var invokedIsTURNMediaRelayOn: Bool?
    var invokedIsTURNMediaRelayOnList = [Bool]()
    var invokedIsTURNMediaRelayOnGetter = false
    var invokedIsTURNMediaRelayOnGetterCount = 0
    var stubbedIsTURNMediaRelayOn: Bool! = false

    var isTURNMediaRelayOn: Bool {
        set {
            invokedIsTURNMediaRelayOnSetter = true
            invokedIsTURNMediaRelayOnSetterCount += 1
            invokedIsTURNMediaRelayOn = newValue
            invokedIsTURNMediaRelayOnList.append(newValue)
        }
        get {
            invokedIsTURNMediaRelayOnGetter = true
            invokedIsTURNMediaRelayOnGetterCount += 1
            return stubbedIsTURNMediaRelayOn
        }
    }

    var invokedAreInsightsEnabledSetter = false
    var invokedAreInsightsEnabledSetterCount = 0
    var invokedAreInsightsEnabled: Bool?
    var invokedAreInsightsEnabledList = [Bool]()
    var invokedAreInsightsEnabledGetter = false
    var invokedAreInsightsEnabledGetterCount = 0
    var stubbedAreInsightsEnabled: Bool! = false

    var areInsightsEnabled: Bool {
        set {
            invokedAreInsightsEnabledSetter = true
            invokedAreInsightsEnabledSetterCount += 1
            invokedAreInsightsEnabled = newValue
            invokedAreInsightsEnabledList.append(newValue)
        }
        get {
            invokedAreInsightsEnabledGetter = true
            invokedAreInsightsEnabledGetterCount += 1
            return stubbedAreInsightsEnabled
        }
    }

    var invokedCoreSDKLogLevelSetter = false
    var invokedCoreSDKLogLevelSetterCount = 0
    var invokedCoreSDKLogLevel: SDKLogLevel?
    var invokedCoreSDKLogLevelList = [SDKLogLevel]()
    var invokedCoreSDKLogLevelGetter = false
    var invokedCoreSDKLogLevelGetterCount = 0
    var stubbedCoreSDKLogLevel: SDKLogLevel!

    var coreSDKLogLevel: SDKLogLevel {
        set {
            invokedCoreSDKLogLevelSetter = true
            invokedCoreSDKLogLevelSetterCount += 1
            invokedCoreSDKLogLevel = newValue
            invokedCoreSDKLogLevelList.append(newValue)
        }
        get {
            invokedCoreSDKLogLevelGetter = true
            invokedCoreSDKLogLevelGetterCount += 1
            return stubbedCoreSDKLogLevel
        }
    }

    var invokedPlatformSDKLogLevelSetter = false
    var invokedPlatformSDKLogLevelSetterCount = 0
    var invokedPlatformSDKLogLevel: SDKLogLevel?
    var invokedPlatformSDKLogLevelList = [SDKLogLevel]()
    var invokedPlatformSDKLogLevelGetter = false
    var invokedPlatformSDKLogLevelGetterCount = 0
    var stubbedPlatformSDKLogLevel: SDKLogLevel!

    var platformSDKLogLevel: SDKLogLevel {
        set {
            invokedPlatformSDKLogLevelSetter = true
            invokedPlatformSDKLogLevelSetterCount += 1
            invokedPlatformSDKLogLevel = newValue
            invokedPlatformSDKLogLevelList.append(newValue)
        }
        get {
            invokedPlatformSDKLogLevelGetter = true
            invokedPlatformSDKLogLevelGetterCount += 1
            return stubbedPlatformSDKLogLevel
        }
    }

    var invokedSignalingSDKLogLevelSetter = false
    var invokedSignalingSDKLogLevelSetterCount = 0
    var invokedSignalingSDKLogLevel: SDKLogLevel?
    var invokedSignalingSDKLogLevelList = [SDKLogLevel]()
    var invokedSignalingSDKLogLevelGetter = false
    var invokedSignalingSDKLogLevelGetterCount = 0
    var stubbedSignalingSDKLogLevel: SDKLogLevel!

    var signalingSDKLogLevel: SDKLogLevel {
        set {
            invokedSignalingSDKLogLevelSetter = true
            invokedSignalingSDKLogLevelSetterCount += 1
            invokedSignalingSDKLogLevel = newValue
            invokedSignalingSDKLogLevelList.append(newValue)
        }
        get {
            invokedSignalingSDKLogLevelGetter = true
            invokedSignalingSDKLogLevelGetterCount += 1
            return stubbedSignalingSDKLogLevel
        }
    }

    var invokedWebRTCSDKLogLevelSetter = false
    var invokedWebRTCSDKLogLevelSetterCount = 0
    var invokedWebRTCSDKLogLevel: SDKLogLevel?
    var invokedWebRTCSDKLogLevelList = [SDKLogLevel]()
    var invokedWebRTCSDKLogLevelGetter = false
    var invokedWebRTCSDKLogLevelGetterCount = 0
    var stubbedWebRTCSDKLogLevel: SDKLogLevel!

    var webRTCSDKLogLevel: SDKLogLevel {
        set {
            invokedWebRTCSDKLogLevelSetter = true
            invokedWebRTCSDKLogLevelSetterCount += 1
            invokedWebRTCSDKLogLevel = newValue
            invokedWebRTCSDKLogLevelList.append(newValue)
        }
        get {
            invokedWebRTCSDKLogLevelGetter = true
            invokedWebRTCSDKLogLevelGetterCount += 1
            return stubbedWebRTCSDKLogLevel
        }
    }

    var invokedBandwidthProfileModeSetter = false
    var invokedBandwidthProfileModeSetterCount = 0
    var invokedBandwidthProfileMode: BandwidthProfileMode?
    var invokedBandwidthProfileModeList = [BandwidthProfileMode]()
    var invokedBandwidthProfileModeGetter = false
    var invokedBandwidthProfileModeGetterCount = 0
    var stubbedBandwidthProfileMode: BandwidthProfileMode!

    var bandwidthProfileMode: BandwidthProfileMode {
        set {
            invokedBandwidthProfileModeSetter = true
            invokedBandwidthProfileModeSetterCount += 1
            invokedBandwidthProfileMode = newValue
            invokedBandwidthProfileModeList.append(newValue)
        }
        get {
            invokedBandwidthProfileModeGetter = true
            invokedBandwidthProfileModeGetterCount += 1
            return stubbedBandwidthProfileMode
        }
    }

    var invokedMaxSubscriptionBitrateSetter = false
    var invokedMaxSubscriptionBitrateSetterCount = 0
    var invokedMaxSubscriptionBitrate: Int?
    var invokedMaxSubscriptionBitrateList = [Int?]()
    var invokedMaxSubscriptionBitrateGetter = false
    var invokedMaxSubscriptionBitrateGetterCount = 0
    var stubbedMaxSubscriptionBitrate: Int!

    var maxSubscriptionBitrate: Int? {
        set {
            invokedMaxSubscriptionBitrateSetter = true
            invokedMaxSubscriptionBitrateSetterCount += 1
            invokedMaxSubscriptionBitrate = newValue
            invokedMaxSubscriptionBitrateList.append(newValue)
        }
        get {
            invokedMaxSubscriptionBitrateGetter = true
            invokedMaxSubscriptionBitrateGetterCount += 1
            return stubbedMaxSubscriptionBitrate
        }
    }

    var invokedDominantSpeakerPrioritySetter = false
    var invokedDominantSpeakerPrioritySetterCount = 0
    var invokedDominantSpeakerPriority: TrackPriority?
    var invokedDominantSpeakerPriorityList = [TrackPriority]()
    var invokedDominantSpeakerPriorityGetter = false
    var invokedDominantSpeakerPriorityGetterCount = 0
    var stubbedDominantSpeakerPriority: TrackPriority!

    var dominantSpeakerPriority: TrackPriority {
        set {
            invokedDominantSpeakerPrioritySetter = true
            invokedDominantSpeakerPrioritySetterCount += 1
            invokedDominantSpeakerPriority = newValue
            invokedDominantSpeakerPriorityList.append(newValue)
        }
        get {
            invokedDominantSpeakerPriorityGetter = true
            invokedDominantSpeakerPriorityGetterCount += 1
            return stubbedDominantSpeakerPriority
        }
    }

    var invokedTrackSwitchOffModeSetter = false
    var invokedTrackSwitchOffModeSetterCount = 0
    var invokedTrackSwitchOffMode: TrackSwitchOffMode?
    var invokedTrackSwitchOffModeList = [TrackSwitchOffMode]()
    var invokedTrackSwitchOffModeGetter = false
    var invokedTrackSwitchOffModeGetterCount = 0
    var stubbedTrackSwitchOffMode: TrackSwitchOffMode!

    var trackSwitchOffMode: TrackSwitchOffMode {
        set {
            invokedTrackSwitchOffModeSetter = true
            invokedTrackSwitchOffModeSetterCount += 1
            invokedTrackSwitchOffMode = newValue
            invokedTrackSwitchOffModeList.append(newValue)
        }
        get {
            invokedTrackSwitchOffModeGetter = true
            invokedTrackSwitchOffModeGetterCount += 1
            return stubbedTrackSwitchOffMode
        }
    }

    var invokedRemoteRoomTypeSetter = false
    var invokedRemoteRoomTypeSetterCount = 0
    var invokedRemoteRoomType: CreateTwilioAccessTokenResponse.RoomType?
    var invokedRemoteRoomTypeList = [CreateTwilioAccessTokenResponse.RoomType?]()
    var invokedRemoteRoomTypeGetter = false
    var invokedRemoteRoomTypeGetterCount = 0
    var stubbedRemoteRoomType: CreateTwilioAccessTokenResponse.RoomType!

    var remoteRoomType: CreateTwilioAccessTokenResponse.RoomType? {
        set {
            invokedRemoteRoomTypeSetter = true
            invokedRemoteRoomTypeSetterCount += 1
            invokedRemoteRoomType = newValue
            invokedRemoteRoomTypeList.append(newValue)
        }
        get {
            invokedRemoteRoomTypeGetter = true
            invokedRemoteRoomTypeGetterCount += 1
            return stubbedRemoteRoomType
        }
    }

    var invokedClientTrackSwitchOffControlSetter = false
    var invokedClientTrackSwitchOffControlSetterCount = 0
    var invokedClientTrackSwitchOffControl: ClientTrackSwitchOffControl?
    var invokedClientTrackSwitchOffControlList = [ClientTrackSwitchOffControl]()
    var invokedClientTrackSwitchOffControlGetter = false
    var invokedClientTrackSwitchOffControlGetterCount = 0
    var stubbedClientTrackSwitchOffControl: ClientTrackSwitchOffControl!

    var clientTrackSwitchOffControl: ClientTrackSwitchOffControl {
        set {
            invokedClientTrackSwitchOffControlSetter = true
            invokedClientTrackSwitchOffControlSetterCount += 1
            invokedClientTrackSwitchOffControl = newValue
            invokedClientTrackSwitchOffControlList.append(newValue)
        }
        get {
            invokedClientTrackSwitchOffControlGetter = true
            invokedClientTrackSwitchOffControlGetterCount += 1
            return stubbedClientTrackSwitchOffControl
        }
    }

    var invokedVideoContentPreferencesModeSetter = false
    var invokedVideoContentPreferencesModeSetterCount = 0
    var invokedVideoContentPreferencesMode: VideoContentPreferencesMode?
    var invokedVideoContentPreferencesModeList = [VideoContentPreferencesMode]()
    var invokedVideoContentPreferencesModeGetter = false
    var invokedVideoContentPreferencesModeGetterCount = 0
    var stubbedVideoContentPreferencesMode: VideoContentPreferencesMode!

    var videoContentPreferencesMode: VideoContentPreferencesMode {
        set {
            invokedVideoContentPreferencesModeSetter = true
            invokedVideoContentPreferencesModeSetterCount += 1
            invokedVideoContentPreferencesMode = newValue
            invokedVideoContentPreferencesModeList.append(newValue)
        }
        get {
            invokedVideoContentPreferencesModeGetter = true
            invokedVideoContentPreferencesModeGetterCount += 1
            return stubbedVideoContentPreferencesMode
        }
    }

    var invokedReset = false
    var invokedResetCount = 0

    func reset() {
        invokedReset = true
        invokedResetCount += 1
    }

    var invokedStart = false
    var invokedStartCount = 0

    func start() {
        invokedStart = true
        invokedStartCount += 1
    }
}
