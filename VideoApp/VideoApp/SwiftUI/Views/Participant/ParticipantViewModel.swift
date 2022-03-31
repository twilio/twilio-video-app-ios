//
//  Copyright (C) 2022 Twilio, Inc.
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

/// Participant abstraction so the UI can handle local and remote participants the same way.
struct ParticipantViewModel {
    var identity = ""
    var displayName = ""
    var isYou = false
    var isMuted = false
    var dominantSpeakerStartTime: Date = .distantPast
    var isDominantSpeaker = false
    var cameraTrack: VideoTrack?
    var isCameraTrackSwitchedOff = false
    var shouldMirrorCameraVideo = false
    var shouldFillCameraVideo = false
    var networkQualityLevel: NetworkQualityLevel = .unknown

    /// The UI sometimes needs an empty participant.
    init() {
        
    }

    init(participant: LocalParticipantManager, shouldHideYou: Bool = false) {
        identity = participant.identity
        displayName = identity + (shouldHideYou ? "" : " (You)")
        isYou = true
        isMuted = !participant.isMicOn

        if let cameraTrack = participant.cameraTrack, cameraTrack.isEnabled {
            self.cameraTrack = cameraTrack
        } else {
            cameraTrack = nil
        }
        
        shouldMirrorCameraVideo = true
        networkQualityLevel = participant.networkQualityLevel
    }
    
    init(participant: RemoteParticipantManager) {
        identity = participant.identity
        displayName = participant.identity
        isMuted = !participant.isMicOn
        isDominantSpeaker = participant.isDominantSpeaker
        dominantSpeakerStartTime = participant.dominantSpeakerStartTime
        cameraTrack = participant.cameraTrack
        isCameraTrackSwitchedOff = participant.isCameraTrackSwitchedOff
        shouldFillCameraVideo = true
        networkQualityLevel = participant.networkQualityLevel
    }
}

extension ParticipantViewModel: Hashable {
    static func == (lhs: ParticipantViewModel, rhs: ParticipantViewModel) -> Bool {
        lhs.identity == rhs.identity
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identity)
    }
}
