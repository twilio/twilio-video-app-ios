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

import SwiftUI

/// A SwiftUI video view that is automatically removed from the video track when the view is no longer in use.
struct PictureInPictureSourceView: UIViewRepresentable {
    @Binding var participant: ParticipantViewModel

    func makeUIView(context: Context) -> PictureInPictureSetupView {
        let view = PictureInPictureSetupView()
        view.configure(participant: participant)
        return view
    }

    func updateUIView(_ uiView: PictureInPictureSetupView, context: Context) {
        uiView.configure(participant: participant)
    }
    
    static func dismantleUIView(_ uiView: PictureInPictureSetupView, coordinator: ()) {
        uiView.videoView.videoTrack?.removeRenderer(uiView.videoView) // TODO: Improve
    }
}




import AVKit
import Combine
import TwilioVideo
import UIKit

class PictureInPictureSetupView: UIView {
    var videoView: VideoTrackStoringSampleBufferVideoView!
    var placeholderView: PIPPlaceholderView!
    private var pipController: AVPictureInPictureController!
    private var pipVideoCallViewController: AVPictureInPictureVideoCallViewController!
    
    override init(frame: CGRect) {
      super.init(frame: frame)
        videoView = VideoTrackStoringSampleBufferVideoView()
            
        videoView.contentMode = .scaleAspectFill
        
        pipVideoCallViewController = AVPictureInPictureVideoCallViewController()
        
        // Pretty much just for aspect ratio, normally used for pop-over
        pipVideoCallViewController.preferredContentSize = CGSize(width: 100, height: 150)

        placeholderView = PIPPlaceholderView()
        pipVideoCallViewController.view.addSubview(placeholderView)

        pipVideoCallViewController.view.addSubview(videoView)
        
        videoView.translatesAutoresizingMaskIntoConstraints = false;
        
        let constraints = [
            videoView.leadingAnchor.constraint(equalTo: pipVideoCallViewController.view.leadingAnchor),
            videoView.trailingAnchor.constraint(equalTo: pipVideoCallViewController.view.trailingAnchor),
            videoView.topAnchor.constraint(equalTo: pipVideoCallViewController.view.topAnchor),
            videoView.bottomAnchor.constraint(equalTo: pipVideoCallViewController.view.bottomAnchor)
        ]

        NSLayoutConstraint.activate(constraints)

        let pipContentSource = AVPictureInPictureController.ContentSource(
            activeVideoCallSourceView: self,
            contentViewController: pipVideoCallViewController
        )
        
        pipController = AVPictureInPictureController(contentSource: pipContentSource)
        pipController.canStartPictureInPictureAutomaticallyFromInline = true
        pipController.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func configure(participant: ParticipantViewModel) {
        placeholderView.configure(particiipant: participant)
        
        videoView.videoTrack = participant.cameraTrack
//        videoView.alpha = participant.isCameraTrackSwitchedOff || participant.cameraTrack == nil ? 0 : 1
    }
}

extension PictureInPictureSetupView: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStartPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
        print("pip controller delegate: will start")
    }
    
    func pictureInPictureControllerDidStartPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
        print("pip controller delegate: did start")
    }
    
    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        failedToStartPictureInPictureWithError error: Error
    ) {
        print("pip controller delegate: failed to start \(error)")
    }
    
    func pictureInPictureControllerWillStopPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
        print("pip controller delegate: will stop")
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
        print("pip controller delegate: did stop")
    }

    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    ) {
        print("pip controller delegate: restore UI")
    }
}

// TODO: Move to the SDK
class VideoTrackStoringSampleBufferVideoView: SampleBufferVideoView {
    var videoTrack: VideoTrack? {
        didSet {
            guard oldValue != videoTrack else { return }
            
            oldValue?.removeRenderer(self)
            
            if let videoTrack = videoTrack {
                videoTrack.addRenderer(self)
            }
        }
    }
}
