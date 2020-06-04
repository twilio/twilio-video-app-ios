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

import IGListDiffKit
import TwilioVideo

class RemoteParticipant: NSObject, Participant {
    let shouldMirrorCameraVideo = false
    let isRemote = true
    var identity: String { participant.identity }
    var networkQualityLevel: NetworkQualityLevel { participant.networkQualityLevel }
    var isMicOn: Bool {
        guard let micTrack = participant.remoteAudioTracks.first else { return false }
        
        return micTrack.isTrackSubscribed && micTrack.isTrackEnabled
    }
    var isDominantSpeaker = false
    var isPinned = false
    private(set) var cameraTrack: VideoTrack?
    private(set) var screenTrack: VideoTrack?
    private let participant: TwilioVideo.RemoteParticipant
    private weak var delegate: ParticipantDelegate?

    init(participant: TwilioVideo.RemoteParticipant, delegate: ParticipantDelegate) {
        self.participant = participant
        self.delegate = delegate
        super.init()
        participant.delegate = self
    }
    
    private func sendUpdate() {
        delegate?.didUpdate(participant: self)
    }
}

extension RemoteParticipant: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        identity as NSString
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        true // Don't use this to detect updates because the SDK tells us when a participant updates
    }
}

extension RemoteParticipant: RemoteParticipantDelegate {
    func remoteParticipantDidEnableVideoTrack(
        participant: TwilioVideo.RemoteParticipant,
        publication: RemoteVideoTrackPublication
    ) {
        sendUpdate()
    }
    
    func remoteParticipantDidDisableVideoTrack(
        participant: TwilioVideo.RemoteParticipant,
        publication: RemoteVideoTrackPublication
    ) {
        sendUpdate()
    }
    
    func remoteParticipantSwitchedOnVideoTrack(
        participant: TwilioVideo.RemoteParticipant,
        track: TwilioVideo.RemoteVideoTrack
    ) {
        sendUpdate()
    }

    func remoteParticipantSwitchedOffVideoTrack(
        participant: TwilioVideo.RemoteParticipant,
        track: TwilioVideo.RemoteVideoTrack
    ) {
        sendUpdate()
    }
    
    func didSubscribeToVideoTrack(
        videoTrack: TwilioVideo.RemoteVideoTrack,
        publication: RemoteVideoTrackPublication,
        participant: TwilioVideo.RemoteParticipant
    ) {
        guard let source = videoTrack.source else { return }

        switch source {
        case .camera: cameraTrack = RemoteVideoTrack(track: videoTrack)
        case .screen: screenTrack = RemoteVideoTrack(track: videoTrack)
        }
        
        sendUpdate()
    }
    
    func didUnsubscribeFromVideoTrack(
        videoTrack: TwilioVideo.RemoteVideoTrack,
        publication: RemoteVideoTrackPublication,
        participant: TwilioVideo.RemoteParticipant
    ) {
        guard let source = videoTrack.source else { return }

        switch source {
        case .camera: cameraTrack = nil
        case .screen: screenTrack = nil
        }
        
        sendUpdate()
    }
    
    func remoteParticipantDidEnableAudioTrack(
        participant: TwilioVideo.RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        sendUpdate()
    }
    
    func remoteParticipantDidDisableAudioTrack(
        participant: TwilioVideo.RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        sendUpdate()
    }
    
    func didSubscribeToAudioTrack(
        audioTrack: RemoteAudioTrack,
        publication: RemoteAudioTrackPublication,
        participant: TwilioVideo.RemoteParticipant
    ) {
        sendUpdate()
    }
    
    func didUnsubscribeFromAudioTrack(
        audioTrack: RemoteAudioTrack,
        publication: RemoteAudioTrackPublication,
        participant: TwilioVideo.RemoteParticipant
    ) {
        sendUpdate()
    }

    func remoteParticipantNetworkQualityLevelDidChange(
        participant: TwilioVideo.RemoteParticipant,
        networkQualityLevel: NetworkQualityLevel
    ) {
        sendUpdate()
    }
}

private extension TwilioVideo.RemoteVideoTrack {
    var source: VideoSource? { VideoSource(trackName: name) }
}
