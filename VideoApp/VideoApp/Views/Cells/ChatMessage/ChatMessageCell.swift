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

class ChatMessageCell: UITableViewCell, NibLoadableView {
    struct Config {
        let message: String
        let isAuthorYou: Bool
    }
    
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bubbleView.layer.cornerRadius = 16
    }
    
    func configure(config: Config) {
        messageLabel.text = config.message
        bubbleView.backgroundColor = config.isAuthorYou ? .youBubbleColor : .defaultBubbleColor
    }
}

private extension UIColor {
    static let defaultBubbleColor = UIColor(hex: 0xE1E3EA)
    static let youBubbleColor = UIColor(hex: 0xCCE4FF)
}
