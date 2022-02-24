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
                guard let micTrack = micTrack else { return }
                
                participant?.unpublishAudioTrack(micTrack)
                self.micTrack = nil
            }
            
            changePublisher.send(self)
        }
    }
    var isCameraOn = false {
        didSet {
            guard oldValue != isCameraOn else { return }
            
            if isCameraOn {
                let sourceOptions = CameraSourceOptions { builder in
                    guard let scene = self.app.windows.filter({ $0.isKeyWindow }).first?.windowScene else { return }
                    
                    builder.orientationTracker = UserInterfaceTracker(scene: scene)
                }
                
                guard
                    let cameraSource = CameraSource(options: sourceOptions, delegate: self),
                    let captureDevice = CameraSource.captureDevice(position: .front),
                    let cameraTrack = LocalVideoTrack(source: cameraSource, enabled: true, name: TrackName.camera)
                else {
                    return
                }
                
                cameraSource.startCapture(device: captureDevice) { _, _, error in
                    if let error = error {
                        print("Start capture error: \(error)")
                    }
                }

                participant?.publishVideoTrack(cameraTrack)
                self.cameraSource = cameraSource
                self.cameraTrack = cameraTrack
            } else {
                if let cameraTrack = cameraTrack {
                    participant?.unpublishVideoTrack(cameraTrack)
                }
                
                cameraSource?.stopCapture()
                cameraSource = nil
                cameraTrack = nil
            }

            changePublisher.send(self)
        }
    }
    var participant: LocalParticipant? {
        didSet {
            participant?.delegate = self
        }
    }
    private(set) var micTrack: LocalAudioTrack?
    private(set) var cameraTrack: LocalVideoTrack?
    private let app = UIApplication.shared
    private var cameraSource: CameraSource?
    
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

extension LocalParticipantManager: CameraSourceDelegate {
    func cameraSourceWasInterrupted(source: CameraSource, reason: AVCaptureSession.InterruptionReason) {
        cameraTrack?.isEnabled = false
        changePublisher.send(self)
    }

    func cameraSourceInterruptionEnded(source: CameraSource) {
        cameraTrack?.isEnabled = true
        changePublisher.send(self)
    }
}
