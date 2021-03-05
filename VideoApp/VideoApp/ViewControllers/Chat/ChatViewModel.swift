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

import Foundation

protocol ChatViewModelDelegate: AnyObject {
    func didReceiveNewMessage(indexPath: IndexPath)
}

protocol ChatViewModel: AnyObject {
    var delegate: ChatViewModelDelegate? { get set }
    var isUserReadingMessages: Bool { get set }
    func numberOfSections() -> Int
    func numberOfRowsInSection(section: Int) -> Int
    func configForSection(section: Int) -> ChatHeaderView.Config
    func configForRow(indexPath: IndexPath) -> ChatMessageCell.Config
}

class ChatViewModelImpl: ChatViewModel {
    weak var delegate: ChatViewModelDelegate?
    var isUserReadingMessages: Bool {
        get { chatStore.isUserReadingMessages }
        set { chatStore.isUserReadingMessages = newValue }
    }
    private let authStore: AuthStoreReading
    private let chatStore: ChatStoreWriting
    
    init(authStore: AuthStoreReading, chatStore: ChatStoreWriting, notificationCenter: NotificationCenterProtocol) {
        self.authStore = authStore
        self.chatStore = chatStore
        
        notificationCenter.addObserver(
            self,
            selector: #selector(handleChatStoreUpdate),
            name: .chatStoreUpdate,
            object: chatStore
        )
    }
    
    func numberOfSections() -> Int {
        chatStore.messages.count
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        1
    }
    
    func configForSection(section: Int) -> ChatHeaderView.Config {
        let message = chatStore.messages[section]

        return ChatHeaderView.Config(
            author: message.author,
            isAuthorYou: message.author == authStore.userDisplayName,
            dateCreated: message.dateCreated
        )
    }
    
    func configForRow(indexPath: IndexPath) -> ChatMessageCell.Config {
        let message = chatStore.messages[indexPath.section]

        switch message.messageType {
        case .text:
            let textMessage = message as! ChatTextMessage

            return ChatMessageCell.Config(
                message: textMessage.body,
                isAuthorYou: textMessage.author == authStore.userDisplayName
            )
        case .file:
            let fileMessage = chatStore.messages.last as! ChatFileMessage
            
            return ChatMessageCell.Config(
                message: fileMessage.fileName,
                isAuthorYou: fileMessage.author == authStore.userDisplayName
            )
        }
    }
    
    @objc private func handleChatStoreUpdate(_ notification: Notification) {
        guard let payload = notification.payload as? ChatStoreUpdate else { return }

        switch payload {
        case .didChangeConnectionState, .didChangeHasUnreadMessage: break
        case let .didReceiveNewMessage(index):
            delegate?.didReceiveNewMessage(indexPath: IndexPath(row: 0, section: index))
        }
    }
}
