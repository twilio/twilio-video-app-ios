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

import TwilioVideo

@objc class ConnectOptionsFactory: NSObject {
    private let appSettingsStore: AppSettingsStoreWriting = AppSettingsStore.shared
    
    @objc func makeConnectOptions(
        accessToken: String,
        roomName: String,
        audioTracks: [LocalAudioTrack],
        videoTracks: [TwilioVideo.LocalVideoTrack]
    ) -> ConnectOptions {
        ConnectOptions(token: accessToken) { builder in
            var videoBitrate: UInt {
                switch self.appSettingsStore.videoCodec {
                case .h264: return 1_200
                case .vp8: return 1_200
                case .vp8SimulcastVGA: return 0
                case .vp8SimulcastHD: return 1_600
                }
            }
            
            builder.roomName = roomName
            builder.audioTracks = audioTracks
            builder.videoTracks = videoTracks
            builder.isDominantSpeakerEnabled = true
            builder.isNetworkQualityEnabled = true
            builder.networkQualityConfiguration = NetworkQualityConfiguration(
                localVerbosity: .minimal,
                remoteVerbosity: .minimal
            )
            builder.bandwidthProfileOptions = BandwidthProfileOptions(
                videoOptions: VideoBandwidthProfileOptions { builder in
                    builder.mode = TwilioVideo.BandwidthProfileMode(setting: self.appSettingsStore.bandwidthProfileMode)
                    builder.maxSubscriptionBitrate = self.appSettingsStore.maxSubscriptionBitrate as NSNumber?
                    builder.maxTracks = self.appSettingsStore.maxTracks as NSNumber?
                    builder.dominantSpeakerPriority = Track.Priority(setting: self.appSettingsStore.dominantSpeakerPriority)
                    builder.trackSwitchOffMode = Track.SwitchOffMode(setting: self.appSettingsStore.trackSwitchOffMode)
                    let renderDimensions = VideoRenderDimensions()
                    renderDimensions.low = VideoDimensions(setting: self.appSettingsStore.lowRenderDimensions)
                    renderDimensions.standard = VideoDimensions(setting: self.appSettingsStore.standardRenderDimensions)
                    renderDimensions.high = VideoDimensions(setting: self.appSettingsStore.highRenderDimensions)
                    builder.renderDimensions = renderDimensions
                }
            )
            builder.preferredVideoCodecs = [TwilioVideo.VideoCodec.make(setting: self.appSettingsStore.videoCodec)]
            builder.encodingParameters = EncodingParameters(audioBitrate: 16, videoBitrate: videoBitrate)
            
            if self.appSettingsStore.isTURNMediaRelayOn {
                builder.iceOptions = IceOptions() { builder in
                    builder.abortOnIceServersTimeout = true
                    builder.iceServersTimeout = 30
                    builder.transportPolicy = .relay
                }
            }
        }
    }
}

private extension TwilioVideo.VideoCodec {
    static func make(setting: VideoCodec) -> TwilioVideo.VideoCodec {
        switch setting {
        case .h264: return H264Codec()
        case .vp8: return Vp8Codec(simulcast: false)
        case .vp8SimulcastVGA, .vp8SimulcastHD: return Vp8Codec(simulcast: true)
        }
    }
}

private extension TwilioVideo.BandwidthProfileMode {
    init?(setting: BandwidthProfileMode) {
        switch setting {
        case .serverDefault: return nil
        case .collaboration: self = .collaboration
        case .grid: self = .grid
        case .presentation: self = .presentation
        }
    }
}

private extension Track.Priority {
    init?(setting: TrackPriority) {
        switch setting {
        case .serverDefault: return nil
        case .low: self = .low
        case .standard: self = .standard
        case .high: self = .high
        }
    }
}

private extension Track.SwitchOffMode {
    init?(setting: TrackSwitchOffMode) {
        switch setting {
        case .serverDefault: return nil
        case .disabled: self = .disabled
        case .detected: self = .detected
        case .predicted: self = .predicted
        }
    }
}

private extension VideoDimensions {
    convenience init?(setting: VideoDimensionsName) {
        switch setting {
        case .serverDefault: return nil
        case .cif: self.init(width: 352, height: 288)
        case .vga: self.init(width: 640, height: 480)
        case .wvga: self.init(width: 800, height: 480)
        case .hd540P: self.init(width: 960, height: 540)
        case .hd720P: self.init(width: 1280, height: 720)
        case .hd960P: self.init(width: 1280, height: 960)
        case .hdStandard1080P: self.init(width: 1440, height: 1080)
        case .hdWidescreen1080P: self.init(width: 1920, height: 1080)
        }
    }
}
