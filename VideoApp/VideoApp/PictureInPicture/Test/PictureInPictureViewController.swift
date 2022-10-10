//
//  PictureInPictureViewController.swift
//  VideoApp
//
//  Created by Tim Rozum on 8/8/22.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import AVKit
import Combine
import UIKit
import TwilioVideo

class PictureInPictureViewController: UIViewController {
    @IBOutlet weak var videoView: VideoTrackStoringVideoView!

    var callManager: CallManager!
    var roomManager: RoomManager!

    private let accessTokenStore = TwilioAccessTokenStore()
    private var pipController: AVPictureInPictureController!
    private var pipVideoCallViewController: AVPictureInPictureVideoCallViewController!
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let sampleBufferVideoCallView = SampleBufferVideoView()
        sampleBufferVideoCallView.contentMode = .scaleAspectFit

        pipVideoCallViewController = AVPictureInPictureVideoCallViewController()
        
        // Pretty much just for aspect ratio, normally used for pop-over
        pipVideoCallViewController.preferredContentSize = CGSize(width: 200, height: 400)
//        pipVideoCallViewController.preferredContentSize = CGSize(width: 1080, height: 1920)
        
        pipVideoCallViewController.view.addSubview(sampleBufferVideoCallView)

        sampleBufferVideoCallView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            sampleBufferVideoCallView.leadingAnchor.constraint(equalTo: pipVideoCallViewController.view.leadingAnchor),
            sampleBufferVideoCallView.trailingAnchor.constraint(equalTo: pipVideoCallViewController.view.trailingAnchor),
            sampleBufferVideoCallView.topAnchor.constraint(equalTo: pipVideoCallViewController.view.topAnchor),
            sampleBufferVideoCallView.bottomAnchor.constraint(equalTo: pipVideoCallViewController.view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)


        sampleBufferVideoCallView.bounds = pipVideoCallViewController.view.frame

        let pipContentSource = AVPictureInPictureController.ContentSource(
            activeVideoCallSourceView: videoView,
            contentViewController: pipVideoCallViewController
        )
        
        pipController = AVPictureInPictureController(contentSource: pipContentSource)
        pipController.canStartPictureInPictureAutomaticallyFromInline = true
        pipController.delegate = self
        
        print("Is pip supported: \(AVPictureInPictureController.isPictureInPictureSupported())")
        print("Is pip possible: \(pipController.isPictureInPicturePossible)")
        
        callManager.connectPublisher
            .sink {
                print("TCR: Did connect")
            }
            .store(in: &subscriptions)
        
        roomManager.remoteParticipantChangePublisher
            .sink { [weak self] participant in
                if let track = participant.cameraTrack {
                    
                    if track.renderers.first(where: { $0 === sampleBufferVideoCallView}) == nil {
                        self?.videoView.videoTrack = track
                        track.addRenderer(sampleBufferVideoCallView)
                        print("TCR: Added renderer")
                    }
                }
            }
            .store(in: &subscriptions)

        callManager.connect(roomName: "tcr")
    }
    
    @IBAction func startPipButtonTap(_ sender: Any) {
        pipController.startPictureInPicture()
    }
    
    @IBAction func stopPictureInPictureButtonTap(_ sender: Any) {
        pipController.stopPictureInPicture()
    }
    
    
}

extension PictureInPictureViewController: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("pip controller delegate: will start")
    }
    
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("pip controller delegate: did start")
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("pip controller delegate: failed to start \(error)")
    }
    
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("pip controller delegate: will stop")
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("pip controller delegate: did stop")
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        print("pip controller delegate: restore UI")
    }
}
