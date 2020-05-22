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
    var invokedEnvironment: Environment?
    var invokedEnvironmentList = [Environment]()
    var invokedEnvironmentGetter = false
    var invokedEnvironmentGetterCount = 0
    var stubbedEnvironment: Environment!

    var environment: Environment {
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

    var invokedTopologySetter = false
    var invokedTopologySetterCount = 0
    var invokedTopology: Topology?
    var invokedTopologyList = [Topology]()
    var invokedTopologyGetter = false
    var invokedTopologyGetterCount = 0
    var stubbedTopology: Topology!

    var topology: Topology {
        set {
            invokedTopologySetter = true
            invokedTopologySetterCount += 1
            invokedTopology = newValue
            invokedTopologyList.append(newValue)
        }
        get {
            invokedTopologyGetter = true
            invokedTopologyGetterCount += 1
            return stubbedTopology
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

    var invokedMaxTracksSetter = false
    var invokedMaxTracksSetterCount = 0
    var invokedMaxTracks: Int?
    var invokedMaxTracksList = [Int?]()
    var invokedMaxTracksGetter = false
    var invokedMaxTracksGetterCount = 0
    var stubbedMaxTracks: Int!

    var maxTracks: Int? {
        set {
            invokedMaxTracksSetter = true
            invokedMaxTracksSetterCount += 1
            invokedMaxTracks = newValue
            invokedMaxTracksList.append(newValue)
        }
        get {
            invokedMaxTracksGetter = true
            invokedMaxTracksGetterCount += 1
            return stubbedMaxTracks
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

    var invokedLowRenderDimensionsSetter = false
    var invokedLowRenderDimensionsSetterCount = 0
    var invokedLowRenderDimensions: VideoDimensionsName?
    var invokedLowRenderDimensionsList = [VideoDimensionsName]()
    var invokedLowRenderDimensionsGetter = false
    var invokedLowRenderDimensionsGetterCount = 0
    var stubbedLowRenderDimensions: VideoDimensionsName!

    var lowRenderDimensions: VideoDimensionsName {
        set {
            invokedLowRenderDimensionsSetter = true
            invokedLowRenderDimensionsSetterCount += 1
            invokedLowRenderDimensions = newValue
            invokedLowRenderDimensionsList.append(newValue)
        }
        get {
            invokedLowRenderDimensionsGetter = true
            invokedLowRenderDimensionsGetterCount += 1
            return stubbedLowRenderDimensions
        }
    }

    var invokedStandardRenderDimensionsSetter = false
    var invokedStandardRenderDimensionsSetterCount = 0
    var invokedStandardRenderDimensions: VideoDimensionsName?
    var invokedStandardRenderDimensionsList = [VideoDimensionsName]()
    var invokedStandardRenderDimensionsGetter = false
    var invokedStandardRenderDimensionsGetterCount = 0
    var stubbedStandardRenderDimensions: VideoDimensionsName!

    var standardRenderDimensions: VideoDimensionsName {
        set {
            invokedStandardRenderDimensionsSetter = true
            invokedStandardRenderDimensionsSetterCount += 1
            invokedStandardRenderDimensions = newValue
            invokedStandardRenderDimensionsList.append(newValue)
        }
        get {
            invokedStandardRenderDimensionsGetter = true
            invokedStandardRenderDimensionsGetterCount += 1
            return stubbedStandardRenderDimensions
        }
    }

    var invokedHighRenderDimensionsSetter = false
    var invokedHighRenderDimensionsSetterCount = 0
    var invokedHighRenderDimensions: VideoDimensionsName?
    var invokedHighRenderDimensionsList = [VideoDimensionsName]()
    var invokedHighRenderDimensionsGetter = false
    var invokedHighRenderDimensionsGetterCount = 0
    var stubbedHighRenderDimensions: VideoDimensionsName!

    var highRenderDimensions: VideoDimensionsName {
        set {
            invokedHighRenderDimensionsSetter = true
            invokedHighRenderDimensionsSetterCount += 1
            invokedHighRenderDimensions = newValue
            invokedHighRenderDimensionsList.append(newValue)
        }
        get {
            invokedHighRenderDimensionsGetter = true
            invokedHighRenderDimensionsGetterCount += 1
            return stubbedHighRenderDimensions
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
