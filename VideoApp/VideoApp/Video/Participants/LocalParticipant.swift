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

class LocalParticipant: NSObject, Participant {
    let identity: String
    let isDominantSpeaker = false
    let isRemote = false
    var cameraTrack: VideoTrack? { cameraManager?.track }
    var screenTrack: VideoTrack? { nil }
    var shouldMirrorCameraVideo: Bool { cameraPosition == .front }
    var networkQualityLevel: NetworkQualityLevel { participant?.networkQualityLevel ?? .unknown }
    var isMicOn: Bool {
        get {
            micTrack?.isEnabled ?? false
        }
        set {
            if newValue {
                guard micTrack == nil, let micTrack = micTrackFactory.makeMicTrack() else { return }
                
                self.micTrack = micTrack
                participant?.publishAudioTrack(micTrack)
            } else {
                guard let micTrack = micTrack else { return }
                
                participant?.unpublishAudioTrack(micTrack)
                self.micTrack = nil
            }

            sendUpdate()
        }
    }
    var isPinned = false
    var isCameraOn: Bool {
        get {
            cameraManager?.track.isEnabled ?? false
        }
        set {
            if newValue {
                guard
                    cameraManager == nil,
                    let cameraManager = cameraManagerFactory.makeCameraManager(position: cameraPosition)
                    else {
                        return
                }
                
                self.cameraManager = cameraManager
                cameraManager.delegate = self
                participant?.publishCameraTrack(cameraManager.track.track)
            } else {
                guard let cameraManager = cameraManager else { return }
                
                participant?.unpublishVideoTrack(cameraManager.track.track)
                self.cameraManager = nil
            }

            sendUpdate()
        }
    }
    var participant: TwilioVideo.LocalParticipant? {
        didSet {
            guard let participant = participant else { return }
            
            participant.delegate = self

            // Sync tracks in case user made changes while connecting to room
            participant.localVideoTracks.compactMap { $0.localTrack }.filter { $0 !== cameraManager?.track.track }.forEach {
                participant.unpublishVideoTrack($0)
            }

            if let cameraTrack = cameraManager?.track.track, !participant.localVideoTracks.contains(where: { $0.localTrack === cameraTrack }) {
                participant.publishCameraTrack(cameraTrack)
            }

            participant.localAudioTracks.compactMap { $0.localTrack }.filter { $0 !== micTrack }.forEach {
                participant.unpublishAudioTrack($0)
            }

            if let micTrack = micTrack, !participant.localAudioTracks.contains(where: { $0.localTrack === micTrack }) {
                participant.publishAudioTrack(micTrack)
            }
        }
    }
    var localCameraTrack: TwilioVideo.LocalVideoTrack? { cameraManager?.track.track }
    var cameraPosition: AVCaptureDevice.Position = .front {
        didSet {
            cameraManager?.position = cameraPosition
            sendUpdate()
        }
    }
    weak var delegate: ParticipantDelegate?
    private(set) var micTrack: LocalAudioTrack?
    private let micTrackFactory: MicTrackFactory
    private let cameraManagerFactory: CameraManagerFactory
    private var cameraManager: CameraManager?

    init(identity: String, micTrackFactory: MicTrackFactory, cameraManagerFactory: CameraManagerFactory) {
        self.identity = identity
        self.micTrackFactory = micTrackFactory
        self.cameraManagerFactory = cameraManagerFactory
    }
    
    private func sendUpdate() {
        delegate?.didUpdate(participant: self)
    }
}

extension LocalParticipant: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        identity as NSString
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        true // Don't use this to detect updates because the SDK tells us when a participant updates
    }
}

extension LocalParticipant: LocalParticipantDelegate {
    func localParticipantDidFailToPublishVideoTrack(
        participant: TwilioVideo.LocalParticipant,
        videoTrack: TwilioVideo.LocalVideoTrack,
        error: Error
    ) {
        print("Failed to publish video track: \(error)")
    }
    
    func localParticipantDidFailToPublishAudioTrack(
        participant: TwilioVideo.LocalParticipant,
        audioTrack: LocalAudioTrack,
        error: Error
    ) {
        print("Failed to publish audio track: \(error)")
    }
    
    func localParticipantNetworkQualityLevelDidChange(
        participant: TwilioVideo.LocalParticipant,
        networkQualityLevel: NetworkQualityLevel
    ) {
        sendUpdate()
    }
}

extension LocalParticipant: CameraManagerDelegate {
    func trackSourceWasInterrupted(track: LocalVideoTrack) {
        track.track.isEnabled = false
        sendUpdate()
    }
    
    func trackSourceInterruptionEnded(track: LocalVideoTrack) {
        track.track.isEnabled = true
        sendUpdate()
    }
}

private extension TwilioVideo.LocalParticipant {
    func publishCameraTrack(_ track: TwilioVideo.LocalVideoTrack) {
        let publicationOptions = LocalTrackPublicationOptions(priority: .low)
        publishVideoTrack(track, publicationOptions: publicationOptions)
    }
}
