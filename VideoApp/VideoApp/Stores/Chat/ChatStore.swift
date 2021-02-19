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

enum ChatState {
    case disconnected
    case connecting
    case connected
}

protocol ChatStoreDelegate: AnyObject {
    func didConnect()
}

class ChatStore: NSObject {
    weak var delegate: ChatStoreDelegate?
    private(set) var state: ChatState = .disconnected
    private(set) var messages: [TCHMessage] = []
    private var client: TwilioConversationsClient?
    private var conversation: TCHConversation?
    private var conversationName = ""
    
    func connect(accessToken: String, conversationName: String) {
        guard state == .disconnected else { fatalError("Connection already in progress.") }
        
        self.conversationName = conversationName
        
        TwilioConversationsClient.conversationsClient(
            withToken: accessToken,
            properties: nil,
            delegate: self
        ) { _, client in // TODO: Make sure weak self is not required
            guard let client = client else {
                self.state = .disconnected
                return
            }
            
           self.client = client
        }
    }

    func disconnect(completion: (() -> Void)? = nil) {
        conversation?.leave { [weak self] _ in // TODO: Make sure all closures are called on main queue
            guard let self = self else { return }

            self.client?.shutdown()
            self.client = nil
            self.conversation = nil
            self.messages = []
            self.state = .disconnected
            completion?()
        }
    }
    
    private func getMessages() {
        conversation?.getLastMessages(withCount: 100) { [weak self] _, messages in
            guard let self = self, let messages = messages else { return }
            
            self.messages = messages
            self.state = .connected
            self.delegate?.didConnect()
        }
    }
}

extension ChatStore: TwilioConversationsClientDelegate {
    func conversationsClient(
        _ client: TwilioConversationsClient,
        synchronizationStatusUpdated status: TCHClientSynchronizationStatus
    ) {
        guard status == .completed else { return }

        client.conversation(withSidOrUniqueName: conversationName) { [weak self] _, conversation in
            guard let self = self, let conversation = conversation else { return }
            
            self.conversation = conversation
            self.getMessages()
        }
    }
}
