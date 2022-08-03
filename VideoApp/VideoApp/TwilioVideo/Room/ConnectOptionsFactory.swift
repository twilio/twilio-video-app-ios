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

class ConnectOptionsFactory: NSObject {
    private let appSettingsStore: AppSettingsStoreWriting = AppSettingsStore.shared

    func makeConnectOptions(
        accessToken: String,
        roomName: String,
        uuid: UUID,
        audioTracks: [LocalAudioTrack],
        videoTracks: [TwilioVideo.LocalVideoTrack]
    ) -> ConnectOptions {
        ConnectOptions(token: accessToken) { builder in
            var videoBitrate: UInt {
                switch self.appSettingsStore.videoCodec {
                // Automatic encoding and video bitrate controls are mutually exclusive.
                case .auto: return 0
                case .h264: return 1_200
                case .vp8: return 1_200
                case .vp8Simulcast: return self.appSettingsStore.videoSize == .quarterHD ? 1_600 : 0
                }
            }

            builder.roomName = roomName
            builder.uuid = uuid
            builder.audioTracks = audioTracks
            builder.videoTracks = videoTracks
            builder.isDominantSpeakerEnabled = true
            builder.isNetworkQualityEnabled = true
            builder.areInsightsEnabled = self.appSettingsStore.areInsightsEnabled
            builder.networkQualityConfiguration = NetworkQualityConfiguration(
                localVerbosity: .minimal,
                remoteVerbosity: .minimal
            )
            builder.bandwidthProfileOptions = BandwidthProfileOptions(
                videoOptions: VideoBandwidthProfileOptions { builder in
                    builder.mode = TwilioVideo.BandwidthProfileMode(setting: self.appSettingsStore.bandwidthProfileMode)
                    builder.maxSubscriptionBitrate = self.appSettingsStore.maxSubscriptionBitrate as NSNumber?
                    builder.dominantSpeakerPriority = Track.Priority(setting: self.appSettingsStore.dominantSpeakerPriority)
                    builder.trackSwitchOffMode = Track.SwitchOffMode(setting: self.appSettingsStore.trackSwitchOffMode)
                    builder.clientTrackSwitchOffControl = TwilioVideo.ClientTrackSwitchOffControl(setting:self.appSettingsStore.clientTrackSwitchOffControl)
                    builder.contentPreferencesMode = TwilioVideo.VideoContentPreferencesMode(setting: self.appSettingsStore.videoContentPreferencesMode)
                }
            )
                        
            // At the moment automatic encoding is mutually exclusive with manual video bitrate and codec controls.
            if self.appSettingsStore.videoCodec == .auto {
                builder.videoEncodingMode = .auto
            } else {
                builder.preferredVideoCodecs = [TwilioVideo.VideoCodec.make(setting: self.appSettingsStore.videoCodec)]
            }
            builder.encodingParameters = EncodingParameters(audioBitrate: 16, videoBitrate: videoBitrate)

            if self.appSettingsStore.isTURNMediaRelayOn {
                builder.iceOptions = IceOptions() { builder in
                    builder.transportPolicy = .relay
                }
            }
        }
    }
}

private extension TwilioVideo.VideoCodec {
    static func make(setting: VideoCodec) -> TwilioVideo.VideoCodec {
        switch setting {
        case .auto: return Vp8Codec(simulcast: true)
        case .h264: return H264Codec()
        case .vp8: return Vp8Codec(simulcast: false)
        case .vp8Simulcast: return Vp8Codec(simulcast: true)
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

private extension TwilioVideo.ClientTrackSwitchOffControl {
    init?(setting: ClientTrackSwitchOffControl) {
        switch setting {
        case .sdkDefault: return nil
        case .auto: self = .auto
        case .manual: self = .manual
        }
    }
}

private extension TwilioVideo.VideoContentPreferencesMode {
    init?(setting: VideoContentPreferencesMode) {
        switch setting {
        case .sdkDefault: return nil
        case .auto: self = .auto
        case .manual: self = .manual
        }
    }
}
