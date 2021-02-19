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

enum ChatConnectionState {
    case disconnected
    case connecting
    case connected
}

protocol ChatStoreDelegate: AnyObject {
    func didConnect()
}

class ChatStore: NSObject {
    weak var delegate: ChatStoreDelegate?
    private(set) var connectionState: ChatConnectionState = .disconnected
    private(set) var messages: [TCHMessage] = []
    private var client: TwilioConversationsClient?
    private var conversation: TCHConversation?
    private var conversationName = ""
    
    func connect(accessToken: String, conversationName: String) {
        if connectionState != .disconnected {
            disconnect()
        }

        connectionState = .connecting // TODO: Post notification
        self.conversationName = conversationName
        
        TwilioConversationsClient.conversationsClient(
            withToken: accessToken,
            properties: nil,
            delegate: self
        ) { [weak self] _, client in
            guard let client = client else { self?.disconnect(); return }
            
            self?.client = client
        }
    }

    func disconnect() {
        client?.shutdown()
        client = nil
        conversation = nil
        messages = []
        conversationName = ""
        connectionState = .disconnected
        // TODO: Post notification
    }

    private func getConversation() {
        client?.conversation(withSidOrUniqueName: conversationName) { [weak self] _, conversation in
            guard let conversation = conversation else { self?.disconnect(); return }

            self?.conversation = conversation
            self?.getMessages()
        }
    }
    
    private func getMessages() {
        conversation?.getLastMessages(withCount: 100) { [weak self] _, messages in
            guard let messages = messages else { self?.disconnect(); return }
            
            self?.messages = messages
            self?.connectionState = .connected
            self?.delegate?.didConnect()
        }
    }
}

extension ChatStore: TwilioConversationsClientDelegate {
    func conversationsClient(
        _ client: TwilioConversationsClient,
        synchronizationStatusUpdated status: TCHClientSynchronizationStatus
    ) {
        switch status {
        case .started, .conversationsListCompleted: return
        case .completed: getConversation()
        case .failed: disconnect()
        @unknown default: return
        }
    }
}
