//
//  Copyright (C) 2021 Twilio, Inc.
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
    var shouldMirrorCameraVideo = false

    /// The UI sometimes needs an empty participant.
    init() {
        
    }

    init(participant: LocalParticipantManager) {
        identity = participant.identity
        displayName = "You"
        isYou = true
        isMuted = !participant.isMicOn

        if let cameraTrack = participant.cameraTrack, cameraTrack.isEnabled {
            self.cameraTrack = cameraTrack
        } else {
            cameraTrack = nil
        }
        
        shouldMirrorCameraVideo = true
    }
    
    init(participant: RemoteParticipantManager) {
        identity = participant.identity
        displayName = participant.identity
        isMuted = !participant.isMicOn
        isDominantSpeaker = participant.isDominantSpeaker
        dominantSpeakerStartTime = participant.dominantSpeakerStartTime
        cameraTrack = participant.cameraTrack
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
