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

class ChatHeaderView: UITableViewHeaderFooterView, NibLoadableView {
    struct Config {
        let author: String
        let isAuthorYou: Bool
        let dateCreated: Date
    }
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    func configure(config: Config) {
        if config.isAuthorYou {
            authorLabel.text = "\(config.author) (You)"
        } else {
            authorLabel.text = config.author
        }
        
        timeLabel.text = ChatHeaderView.dateFormatter.string(from: config.dateCreated).lowercased()
    }
}
