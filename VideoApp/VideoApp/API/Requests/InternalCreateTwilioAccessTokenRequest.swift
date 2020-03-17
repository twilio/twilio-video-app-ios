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

struct InternalCreateTwilioAccessTokenRequest: APIRequest {
    struct Parameters: Encodable {
        enum AppEnvironment: String, Encodable {
            case production
        }
        
        enum Topology: String, Encodable {
            case group
            case peerToPeer = "peer-to-peer"
        }
        
        let identity: String
        let roomName: String
        let appEnvironment = AppEnvironment.production
        let topology: Topology
    }

    let path = "token"
    let parameters: Parameters
    let encoding = APIEncoding.queryStringURL
    let responseType = String.self

    init(identity: String, roomName: String, topology: Parameters.Topology) {
        parameters = Parameters(identity: identity, roomName: roomName, topology: topology)
    }
}
