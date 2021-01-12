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

        darken()
    }

    private func darken() {
        UIView.animate(
            withDuration: 0.6,
            delay: .zero,
            options: .curveEaseOut,
            animations: { self.backgroundColor = .darkRed },
            completion: { _ in self.brighten() }
        )
    }
    
    private func brighten() {
        UIView.animate(
            withDuration: 0.6,
            delay: .zero,
            options: .curveEaseOut,
            animations: { self.backgroundColor = .red },
            completion: { _ in self.darken() }
        )
    }
}

private extension UIColor {
    static let darkRed = UIColor(hex: 0xA90000)
}
