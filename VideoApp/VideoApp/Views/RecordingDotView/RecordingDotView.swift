//
//  Copyright (C) 2021 Twilio, Inc.
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

class RecordingDotView: CircleView {
    override func awakeFromNib() {
        super.awakeFromNib()

        UIView.animateKeyframes(
            withDuration: 1.5,
            delay: .zero,
            options: [.repeat, .autoreverse],
            animations: {
                UIView.addKeyframe(
                    withRelativeStartTime: 0.0,
                    relativeDuration: 0.75,
                    animations: {
                        self.backgroundColor = UIColor(rgb: 0xA90000)
                    }
                )

                UIView.addKeyframe(
                    withRelativeStartTime: 0.5,
                    relativeDuration: 0.75,
                    animations: {
                        self.backgroundColor = .red
                    }
                )
            },
            completion: nil
        )
    }
}

extension UIColor {
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
