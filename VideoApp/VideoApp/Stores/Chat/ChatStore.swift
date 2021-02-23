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

protocol ChatStoreWriting: AnyObject {
    var connectionState: ChatConnectionState { get }
    var messages: [ChatMessageGroup] { get }
    func connect(accessToken: String, conversationName: String)
    func disconnect()
    func sendMessage(_ message: String, completion: @escaping (NSError?) -> Void)
}

class ChatStore: NSObject, ChatStoreWriting {
    enum Update {
        case didChangeConnectionState
    }

    static let shared: ChatStoreWriting = ChatStore()
    private(set) var connectionState: ChatConnectionState = .disconnected {
        didSet { post(.didChangeConnectionState) }
    }
    private(set) var messages: [ChatMessageGroup] = []
    private let notificationCenter = NotificationCenter.default
    private var client: TwilioConversationsClient?
    private var conversation: TCHConversation?
    private var conversationName = ""
    
    func connect(accessToken: String, conversationName: String) {
        if connectionState != .disconnected {
            disconnect()
        }

        connectionState = .connecting
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
    }

    func sendMessage(_ message: String, completion: @escaping (NSError?) -> Void) {
        let options = TCHMessageOptions().withBody(message)
        
        conversation?.sendMessage(with: options) { result, _ in
            completion(result.error)
        }
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
        }
    }
    
    private func post(_ update: Update) {
        notificationCenter.post(name: .chatStoreUpdate, object: self, payload: update)
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
    
    func conversationsClient(
        _ client: TwilioConversationsClient,
        conversation: TCHConversation,
        messageAdded message: TCHMessage
    ) {
        guard conversation.sid == self.conversation?.sid else { return }
        
        
    }
}
