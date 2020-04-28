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

class ParticipantCell: UICollectionViewCell {
    struct Status {
        let isMicOn: Bool
        let networkQualityLevel: NetworkQualityLevel
        let isPinned: Bool
    }
    
    @IBOutlet weak var videoView: VideoView!
    @IBOutlet weak var identityLabel: UILabel!
    @IBOutlet weak var networkQualityImage: UIImageView!
    @IBOutlet weak var pinView: UIView!
    @IBOutlet weak var muteView: UIView!
    
    func configure(participant: Participant) {
        identityLabel.text = participant.identity
        muteView.isHidden = participant.isMicOn
        pinView.isHidden = !participant.isPinned
        
        if let imageName = participant.networkQualityLevel.imageName {
            networkQualityImage.image = UIImage(named: imageName)
        } else {
            networkQualityImage.image = nil
        }

        videoView.configure(
            config: .init(
                videoTrack: participant.cameraTrack,
                shouldMirror: participant.shouldMirrorCameraVideo
            ),
            contentMode: .scaleAspectFill
        )
    }
}

private extension NetworkQualityLevel {
    var imageName: String? {
        switch self {
        case .unknown: return nil
        case .zero: return "network-quality-level-0"
        case .one: return "network-quality-level-1"
        case .two: return "network-quality-level-2"
        case .three: return "network-quality-level-3"
        case .four: return "network-quality-level-4"
        case .five: return "network-quality-level-5"
        @unknown default:
            return nil
        }
    }
}
