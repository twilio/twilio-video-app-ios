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
    var identity: String { participant.identity }
    var cameraTrack: VideoTrack? { participant.remoteVideoTrack(name: TrackName.camera) }
    var screenTrack: VideoTrack? { participant.remoteVideoTrack(name: TrackName.screen) }
    let shouldMirrorCameraVideo = false
    var networkQualityLevel: NetworkQualityLevel { participant.networkQualityLevel }
    let isRemote = true
    var isMicOn: Bool { participant.remoteAudioTracks.first(where: { $0.trackName == TrackName.mic })?.isTrackEnabled == true }
    var isDominantSpeaker = false { didSet { postUpdate() } }
    var isPinned = false
    private let participant: TwilioVideo.RemoteParticipant
    private let notificationCenter: NotificationCenter
    
    init(participant: TwilioVideo.RemoteParticipant, notificationCenter: NotificationCenter) {
        self.participant = participant
        self.notificationCenter = notificationCenter
        super.init()
        participant.delegate = self
    }
    
    private func postUpdate() {
        let update = ParticipantUpdate.didUpdate(participant: self)
        notificationCenter.post(name: .participantUpdate, object: self, payload: update)
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
        postUpdate()
    }
    
    func remoteParticipantDidDisableVideoTrack(
        participant: TwilioVideo.RemoteParticipant,
        publication: RemoteVideoTrackPublication
    ) {
        postUpdate()
    }
    
    func didSubscribeToVideoTrack(
        videoTrack: RemoteVideoTrack,
        publication: RemoteVideoTrackPublication,
        participant: TwilioVideo.RemoteParticipant
    ) {
        postUpdate()
    }
    
    func didUnsubscribeFromVideoTrack(
        videoTrack: RemoteVideoTrack,
        publication: RemoteVideoTrackPublication,
        participant: TwilioVideo.RemoteParticipant
    ) {
        postUpdate()
    }
    
    func remoteParticipantDidEnableAudioTrack(
        participant: TwilioVideo.RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        postUpdate()
    }
    
    func remoteParticipantDidDisableAudioTrack(
        participant: TwilioVideo.RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        postUpdate()
    }
    
    func didSubscribeToAudioTrack(
        audioTrack: RemoteAudioTrack,
        publication: RemoteAudioTrackPublication,
        participant: TwilioVideo.RemoteParticipant
    ) {
        postUpdate()
    }
    
    func didUnsubscribeFromAudioTrack(
        audioTrack: RemoteAudioTrack,
        publication: RemoteAudioTrackPublication,
        participant: TwilioVideo.RemoteParticipant
    ) {
        postUpdate()
    }

    func remoteParticipantNetworkQualityLevelDidChange(
        participant: TwilioVideo.RemoteParticipant,
        networkQualityLevel: NetworkQualityLevel
    ) {
        postUpdate()
    }
}

private extension TwilioVideo.RemoteParticipant {
    func remoteVideoTrack(name: String) -> VideoTrack? {
        remoteVideoTracks.first(where: { $0.trackName.contains(name) })?.remoteTrack
    }
}
