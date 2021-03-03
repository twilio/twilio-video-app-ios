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

class ChatFileMessage: ChatMessage {
    let messageType = ChatMessageType.file
    let author: String
    let dateCreated: Date
    let fileName: String
    var fileSize: UInt { message.mediaSize }
    private let message: TCHMessage

    init?(message: TCHMessage) {
        guard
            message.messageType == .media,
            let fileName = message.mediaFilename,
            let dateCreated = message.dateCreatedAsDate,
            let author = message.author
        else {
            return nil
        }

        self.author = author
        self.dateCreated = dateCreated
        self.message = message
        self.fileName = fileName
    }
    
    func getTemporaryURL(completion: @escaping (Result<String, NSError>) -> Void) {
        message.getMediaContentTemporaryUrl { result, url in
            guard let url = url else {
                completion(.failure(result.error!))
                return
            }
            
            completion(.success(url))
        }
    }
}
