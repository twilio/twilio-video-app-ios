//
//  Copyright (C) 2020 Twilio, Inc.
//

import TwilioVideo

protocol RemoteParticipantManagerDelegate: AnyObject {
    func participantDidChange(_ participant: RemoteParticipantManager)
}

/// Determines remote participant state and sends updates to delegate.
///
/// Also stores dominant speaker state received by the room so that participants contain all participant state
/// which is good for the UI. See `isDominantSpeaker` and `dominantSpeakerStartTime`.
class RemoteParticipantManager: NSObject {
    var identity: String { participant.identity }
    var isMicOn: Bool {
        guard let track = participant.remoteAudioTracks.first else { return false }
        
        return track.isTrackSubscribed && track.isTrackEnabled
    }
    var cameraTrack: VideoTrack? {
        guard
            let publication = participant.remoteVideoTracks.first(where: { $0.trackName.contains(TrackName.camera) }),
            let track = publication.remoteTrack,
            track.isEnabled
        else {
            return nil
        }
        
        return track
    }
    var presentationTrack: VideoTrack? {
        guard
            let publication = participant.remoteVideoTracks.first(where: { $0.trackName.contains(TrackName.screen) }),
            let track = publication.remoteTrack
        else {
            return nil
        }
        
        return track
    }
    var isDominantSpeaker = false {
        didSet {
            dominantSpeakerStartTime = Date()
            delegate?.participantDidChange(self)
        }
    }
    var dominantSpeakerStartTime: Date = .distantPast
    private let participant: RemoteParticipant
    private weak var delegate: RemoteParticipantManagerDelegate?

    init(participant: RemoteParticipant, delegate: RemoteParticipantManagerDelegate) {
        self.participant = participant
        self.delegate = delegate
        super.init()
        participant.delegate = self
    }
}

extension RemoteParticipantManager: RemoteParticipantDelegate {
    func didSubscribeToVideoTrack(
        videoTrack: RemoteVideoTrack,
        publication: RemoteVideoTrackPublication,
        participant: RemoteParticipant
    ) {
        delegate?.participantDidChange(self)
    }
    
    func didUnsubscribeFromVideoTrack(
        videoTrack: RemoteVideoTrack,
        publication: RemoteVideoTrackPublication,
        participant: RemoteParticipant
    ) {
        delegate?.participantDidChange(self)
    }

    func remoteParticipantDidEnableVideoTrack(
        participant: RemoteParticipant,
        publication: RemoteVideoTrackPublication
    ) {
        delegate?.participantDidChange(self)
    }
    
    func remoteParticipantDidDisableVideoTrack(
        participant: RemoteParticipant,
        publication: RemoteVideoTrackPublication
    ) {
        delegate?.participantDidChange(self)
    }

    func didSubscribeToAudioTrack(
        audioTrack: RemoteAudioTrack,
        publication: RemoteAudioTrackPublication,
        participant: RemoteParticipant
    ) {
        delegate?.participantDidChange(self)
    }
    
    func didUnsubscribeFromAudioTrack(
        audioTrack: RemoteAudioTrack,
        publication: RemoteAudioTrackPublication,
        participant: RemoteParticipant
    ) {
        delegate?.participantDidChange(self)
    }

    func remoteParticipantDidEnableAudioTrack(
        participant: RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        delegate?.participantDidChange(self)
    }
    
    func remoteParticipantDidDisableAudioTrack(
        participant: RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        delegate?.participantDidChange(self)
    }
}

//extension RemoteParticipantManager: RemoteDataTrackDelegate {
//    func remoteDataTrackDidReceiveData(remoteDataTrack: RemoteDataTrack, message: Data) {
//        guard let message = try? JSONDecoder(keyDecodingStrategy: .convertFromSnakeCase).decode(RoomMessage.self, from: message) else {
//            return
//        }
//
//        delegate?.participant(self, didSendMessage: message)
//    }
//}
