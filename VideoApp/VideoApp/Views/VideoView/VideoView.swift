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

//import TwilioVideo
//import UIKit
//
//@IBDesignable
//class VideoView: NibView {
//    struct Config {
//        let videoTrack: VideoTrack?
//        let shouldMirror: Bool
//    }
//
//    @IBOutlet weak var videoView: TwilioVideo.VideoView!
//    @IBOutlet weak var errorView: UIView!
//    var shouldRenderVideo = true {
//        didSet {
//            guard let videoTrack = videoTrack else { return }
//            
//            if shouldRenderVideo {
//                guard !videoTrack.isRendered(by: videoView) else { return }
//                
//                videoTrack.addRenderer(videoView)
//                videoView.isHidden = !videoView.hasVideoData
//            } else {
//                videoTrack.removeRenderer(videoView)
//            }
//        }
//    }
//    private var videoTrack: VideoTrack?
//    
//    deinit {
//        videoTrack?.removeRenderer(videoView)
//    }
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//        videoView.delegate = self
//    }
//
//    func configure(config: Config, contentMode: UIView.ContentMode = .scaleAspectFit) {
//        videoView.shouldMirror = config.shouldMirror
//        videoView.contentMode = contentMode
//        errorView.isHidden = !(config.videoTrack?.isSwitchedOff ?? false)
//
//        if let videoTrack = config.videoTrack, videoTrack.isEnabled {
//            if !videoTrack.isRendered(by: videoView) {
//                self.videoTrack?.removeRenderer(videoView)
//                self.videoTrack = videoTrack
//                videoView.isHidden = true
//                
//                if shouldRenderVideo {
//                    videoTrack.addRenderer(videoView)
//                    videoView.isHidden = !videoView.hasVideoData
//                }
//            }
//        } else {
//            videoTrack?.removeRenderer(videoView)
//            videoTrack = nil
//            videoView.isHidden = true
//        }
//    }
//}
//
//extension VideoView: TwilioVideo.VideoViewDelegate {
//    func videoViewDidReceiveData(view: TwilioVideo.VideoView) {
//        videoView.isHidden = false
//    }
//}
//
//private extension VideoTrack {
//    func isRendered(by renderer: VideoRenderer) -> Bool {
//        renderers.first(where: { $0 === renderer }) != nil
//    }
//}
