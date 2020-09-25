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

import Foundation

struct CommunityCreateTwilioAccessTokenResponse: Decodable {
    enum RoomType: String, Codable { // Codable because it's persisted to track changes
        case go = "go"
        case group
        case groupSmall = "group-small"
        case peerToPeer = "peer-to-peer"
        case unknown

        init(from decoder: Decoder) throws {
            self = try RoomType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
        }
    }

    let token: String
    let roomType: RoomType?
}
