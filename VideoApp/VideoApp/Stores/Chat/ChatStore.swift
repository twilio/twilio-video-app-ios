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

protocol ChatStoreDelegate: AnyObject {
    func didJoinChat()
    func didReceiveNewMessage() // Probably need index
}

class ChatStore: NSObject {
    weak var delegate: ChatStoreDelegate?
    private(set) var messages: [TCHMessage] = []
    private var client: TwilioConversationsClient! // TODO: Maybe rename
    private var conversation: TCHConversation?
    private var uniqueName: String!
    
    func start(token: String, uniqueName: String) {
        self.uniqueName = uniqueName
        
        TwilioConversationsClient.conversationsClient(
            withToken: token,
            properties: nil,
            delegate: self
        ) { result, client in // TODO: Make sure weak self is not required
           self.client = client
        }
    }

    func sendMessage(_ message: String) {
        let options = TCHMessageOptions() .withBody(message)
        conversation?.sendMessage(with: options, completion: nil) // Handle errors
    }

    private func loadPreviousMessages() {
        guard let conversation = conversation else { return }
        
        conversation.getLastMessages(withCount: 100) { (result, messages) in
            if let messages = messages {
                self.messages = messages
                DispatchQueue.main.async {
                    self.delegate?.didJoinChat()
                }
            }
        }
    }
}

extension ChatStore: TwilioConversationsClientDelegate {
    func conversationsClient(
        _ client: TwilioConversationsClient,
        synchronizationStatusUpdated status: TCHClientSynchronizationStatus
    ) {
        guard status == .completed else { return } // TODO: Handle all cases

        print("Chat: sync complete")
        
        client.conversation(withSidOrUniqueName: uniqueName) { _, conversation in
            print("Chat: sync complete")

            if let conversation = conversation {
                print("Chat: have conversation")
                self.conversation = conversation
                
                conversation.join(completion: { result in
//                    if result.isSuccessful { // Member already exists?
                        self.loadPreviousMessages()
//                    }
                })
            } else {
                print("Chat: don't have conversation")
                
                let options = [TCHConversationOptionUniqueName: self.uniqueName!] // Remove bang
                
                client.createConversation(options: options) { _, conversation in
                    guard let conversation = conversation else { return }

                    print("Chat: created conversation")
                    
                    self.conversation = conversation
                    
                    if conversation.status == .joined { // Is this really necessary?
                        self.loadPreviousMessages()
                    } else {
                        print("Chat: try to join conversation")
                        
                        conversation.join(completion: { result in
                            if result.isSuccessful {
                                self.loadPreviousMessages()
                            }
                        })
                    }
                }
            }
        }
    }
    
    func conversationsClient(
        _ client: TwilioConversationsClient,
        conversation: TCHConversation,
        messageAdded message: TCHMessage
    ) {
        messages.append(message)

        DispatchQueue.main.async { [weak self] in
            self?.delegate?.didReceiveNewMessage()
        }
    }
}
