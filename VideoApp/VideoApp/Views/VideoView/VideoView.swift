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

import TwilioVideo
import UIKit

protocol VideoViewDelegate: AnyObject {
    func didUpdateStatus(isVideoOn: Bool)
}

@IBDesignable
class VideoView: UIView {
    struct Config {
        let videoTrack: VideoTrack?
        let shouldMirror: Bool
    }

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var errorView: UIView!
    weak var delegate: VideoViewDelegate?
    private var videoTrack: VideoTrack?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("VideoView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    deinit {
//        videoTrack?.removeRenderer(videoView)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        if errorView == nil {
            fatalError("errorView is nil")
        } else if videoView == nil {
            fatalError("videoView is nil")
        }

        videoView.isHidden = false
//        videoView.delegate = self
    }

    func configure(config: Config, contentMode: UIView.ContentMode = .scaleAspectFit) {
//        defer { errorView.isHidden = !(config.videoTrack?.isSwitchedOff ?? false) }
//
//        guard let videoTrack = config.videoTrack, videoTrack.isEnabled else {
//            self.videoTrack?.removeRenderer(videoView)
//            updateStatus(hasVideoData: false)
//            return
//        }
//        guard !videoTrack.isRendered(by: videoView) || videoView.shouldMirror != config.shouldMirror else {
//            return // Don't thrash rendering because it causes empty frames to flash
//        }
//
//        self.videoTrack?.removeRenderer(videoView)
//        self.videoTrack = videoTrack
//        videoTrack.addRenderer(videoView)
//        videoView.shouldMirror = config.shouldMirror
//        videoView.contentMode = contentMode
//        updateStatus(hasVideoData: videoView.hasVideoData)
    }
    
    private func updateStatus(hasVideoData: Bool) {
//        videoView.isHidden = !hasVideoData
        delegate?.didUpdateStatus(isVideoOn: hasVideoData)
    }
}

extension VideoView: TwilioVideo.VideoViewDelegate {
    func videoViewDidReceiveData(view: TwilioVideo.VideoView) {
        updateStatus(hasVideoData: true)
    }
}

private extension VideoTrack {
    func isRendered(by renderer: VideoRenderer) -> Bool {
        renderers.first(where: { $0 === renderer }) != nil
    }
}
