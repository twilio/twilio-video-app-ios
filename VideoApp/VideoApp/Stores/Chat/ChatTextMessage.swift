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

import TwilioConversationsClient

class ChatTextMessage: ChatMessage {
    let author: String
    let dateCreated: Date
    let body: String
    
    init?(message: TCHMessage) {
        guard
            let dateCreated = message.dateCreatedAsDate,
            let author = message.author,
            let body = message.body,
            message.messageType == .text
        else {
            return nil
        }
        
        self.author = author
        self.dateCreated = dateCreated
        self.body = body
    }
}
