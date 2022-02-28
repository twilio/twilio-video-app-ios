//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine
import TwilioVideo

/// Maintains local participant state and uses a publisher to notify subscribers of state changes.
///
/// The microphone and camera may be configured before and after connecting to a video room.
class LocalParticipantManager: NSObject {
    let changePublisher = PassthroughSubject<LocalParticipantManager, Never>()
    let errorPublisher = PassthroughSubject<Error, Never>()
    let identity: String
    var isMicOn: Bool {
        get {
            micTrack?.isEnabled ?? false
        }
        set {
            if newValue {
                guard
                    micTrack == nil,
                    let micTrack = LocalAudioTrack(options: nil, enabled: true, name: TrackName.mic)
                else {
                    return
                }
                
                self.micTrack = micTrack
                participant?.publishAudioTrack(micTrack)
            } else {
                guard let micTrack = micTrack else {
                    return
                }
                
                participant?.unpublishAudioTrack(micTrack)
                self.micTrack = nil
            }
            
            changePublisher.send(self)
        }
    }
    var isCameraOn: Bool {
        get {
            cameraManager?.track.isEnabled ?? false
        }
        set {
            if newValue {
                guard
                    cameraManager == nil,
                    let cameraManager = CameraManager(position: .front)
                else {
                    return
                }
                
                self.cameraManager = cameraManager
                cameraManager.delegate = self
                let publicationOptions = LocalTrackPublicationOptions(priority: .low)
                participant?.publishVideoTrack(cameraManager.track, publicationOptions: publicationOptions)
            } else {
                guard let cameraManager = cameraManager else {
                    return
                }
                
                participant?.unpublishVideoTrack(cameraManager.track)
                self.cameraManager = nil
            }
            
            changePublisher.send(self)
        }
    }
    var participant: LocalParticipant? {
        didSet {
            participant?.delegate = self
        }
    }
    var cameraTrack: LocalVideoTrack? { cameraManager?.track }
    private(set) var micTrack: LocalAudioTrack?
    private var cameraManager: CameraManager?
    
    init(identity: String) {
        self.identity = identity
    }
}

extension LocalParticipantManager: LocalParticipantDelegate {
    func localParticipantDidFailToPublishVideoTrack(
        participant: LocalParticipant,
        videoTrack: LocalVideoTrack,
        error: Error
    ) {
        errorPublisher.send(error)
    }
    
    func localParticipantDidFailToPublishAudioTrack(
        participant: LocalParticipant,
        audioTrack: LocalAudioTrack,
        error: Error
    ) {
        errorPublisher.send(error)
    }
}

extension LocalParticipantManager: CameraManagerDelegate {
    func trackSourceWasInterrupted(track: LocalVideoTrack) {
        track.isEnabled = false
        changePublisher.send(self)
    }

    func trackSourceInterruptionEnded(track: LocalVideoTrack) {
        track.isEnabled = true
        changePublisher.send(self)
    }
}
