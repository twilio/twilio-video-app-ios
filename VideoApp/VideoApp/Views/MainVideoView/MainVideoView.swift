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

import UIKit

@IBDesignable
class MainVideoView: NibView {
    @IBOutlet weak var emptyVideoView: EmptyVideoView!
    @IBOutlet weak var videoView: VideoView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        videoView.delegate = self
    }
    
    func configure(identity: String, videoConfig: VideoView.Config) {
        emptyVideoView.configure(identity: identity)
        videoView.configure(config: videoConfig)
    }
}

extension MainVideoView: VideoViewDelegate {
    func didUpdateStatus(isVideoOn: Bool) {
        emptyVideoView.isHidden = isVideoOn
    }
}
