//
//  Copyright (C) 2019 Twilio, Inc.
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

import Foundation

enum Topology: String, SettingOptions {
    case go
    case group
    case groupSmall
    case peerToPeer
    
    var title: String {
        switch self {
        case .go: return "Go"
        case .group: return "Group"
        case .groupSmall: return "Group Small"
        case .peerToPeer: return "Peer-to-Peer"
        }
    }
}
