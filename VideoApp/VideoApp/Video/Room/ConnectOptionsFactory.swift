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
                    builder.maxTracks = 5
                    builder.dominantSpeakerPriority = Track.Priority(setting: self.appSettingsStore.dominantSpeakerPriority)
                    builder.trackSwitchOffMode = Track.SwitchOffMode(setting: self.appSettingsStore.trackSwitchOffMode)
                }
            )

            switch self.appSettingsStore.videoCodec {
            case .h264:
                builder.preferredVideoCodecs = [H264Codec()]
                builder.encodingParameters = EncodingParameters(audioBitrate: 0, videoBitrate: 1_200)
            case .vp8:
                builder.preferredVideoCodecs = [Vp8Codec(simulcast: false)]
                builder.encodingParameters = EncodingParameters(audioBitrate: 0, videoBitrate: 1_200)
            case .vp8Simulcast:
                builder.preferredVideoCodecs = [Vp8Codec(simulcast: true)]
                
                // Allocate a higher bitrate for the simulcast track with 3 spatial layers
                builder.encodingParameters = EncodingParameters(audioBitrate: 0, videoBitrate: 1_600)
            }
            
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
