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
    var cameraTrack: VideoTrack? { localCameraTrack }
    var screenTrack: VideoTrack? { nil }
    var shouldMirrorCameraVideo: Bool { cameraPosition == .front }
    var networkQualityLevel: NetworkQualityLevel { participant?.networkQualityLevel ?? .unknown }
    let isRemote = false
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

            postUpdate()
        }
    }
    let isDominantSpeaker = false
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
                participant?.publishVideoTrack(cameraManager.track)
            } else {
                guard let cameraManager = cameraManager else { return }
                
                participant?.unpublishVideoTrack(cameraManager.track)
                self.cameraManager = nil
            }

            postUpdate()
        }
    }
    var participant: TwilioVideo.LocalParticipant? {
        didSet { participant?.delegate = self }
    }
    var localCameraTrack: LocalVideoTrack? { cameraManager?.track }
    var cameraPosition: AVCaptureDevice.Position = .front {
        didSet { cameraManager?.position = cameraPosition }
    }
    private(set) var micTrack: LocalAudioTrack?
    private let micTrackFactory: MicTrackFactory
    private let cameraManagerFactory: CameraManagerFactory
    private let notificationCenter: NotificationCenter
    private var cameraManager: CameraManager?

    init(
        identity: String,
        micTrackFactory: MicTrackFactory,
        cameraManagerFactory: CameraManagerFactory,
        notificationCenter: NotificationCenter
    ) {
        self.identity = identity
        self.micTrackFactory = micTrackFactory
        self.cameraManagerFactory = cameraManagerFactory
        self.notificationCenter = notificationCenter
    }

    private func postUpdate() {
        let update = ParticipantUpdate.didUpdate(participant: self)
        notificationCenter.post(name: .participantUpdate, object: self, payload: update)
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
        videoTrack: LocalVideoTrack,
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
        postUpdate()
    }
}

extension LocalParticipant: CameraManagerDelegate {
    func trackSourceWasInterrupted(track: LocalVideoTrack) {
        participant?.unpublishVideoTrack(track)
    }
    
    func trackSourceInterruptionEnded(track: LocalVideoTrack) {
        participant?.publishVideoTrack(track)
    }
}
