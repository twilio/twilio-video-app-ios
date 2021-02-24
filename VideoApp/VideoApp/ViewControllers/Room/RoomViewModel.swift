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

import AVFoundation
import IGListDiffKit

protocol RoomViewModelDelegate: AnyObject {
    func didConnect()
    func didFailToConnect(error: Error)
    func didDisconnect(error: Error?)
    func didUpdateList(diff: ListIndexSetResult)
    func didUpdateParticipant(at index: Int)
    func didUpdateMainParticipant()
    func didUpdateRecording()
    func didUpdateChat()
}

class RoomViewModel {
    weak var delegate: RoomViewModelDelegate?
    var data: RoomViewModelData {
        .init(
            roomName: room.state == .connecting ? "Connecting..." : roomName,
            participants: participantsStore.participants,
            mainParticipant: .init(
                participant: mainParticipantStore.mainParticipant,
                videoTrack: mainParticipantStore.videoTrack
            ),
            isRecording: room.isRecording,
            isChatConnected: chatStore.connectionState == .connected,
            hasUnreadChatMessage: chatStore.hasUnreadMessage
        )
    }
    var isMicOn: Bool {
        get { room.localParticipant.isMicOn }
        set { room.localParticipant.isMicOn = newValue }
    }
    var isCameraOn: Bool {
        get { room.localParticipant.isCameraOn }
        set { room.localParticipant.isCameraOn = newValue }
    }
    var cameraPosition: AVCaptureDevice.Position {
        get { room.localParticipant.cameraPosition }
        set { room.localParticipant.cameraPosition = newValue }
    }
    private let roomName: String
    private let room: Room
    private let participantsStore: ParticipantsStore
    private let mainParticipantStore: MainParticipantStore
    private let chatStore: ChatStoreWriting
    private let notificationCenter: NotificationCenter

    init(
        roomName: String,
        room: Room,
        participantsStore: ParticipantsStore,
        mainParticipantStore: MainParticipantStore,
        chatStore: ChatStoreWriting,
        notificationCenter: NotificationCenter
    ) {
        self.roomName = roomName
        self.room = room
        self.participantsStore = participantsStore
        self.mainParticipantStore = mainParticipantStore
        self.chatStore = chatStore
        self.notificationCenter = notificationCenter
        notificationCenter.addObserver(self, selector: #selector(handleRoomUpdate(_:)), name: .roomUpdate, object: room)
        notificationCenter.addObserver(self, selector: #selector(handleParticipansStoreUpdate(_:)), name: .participantsStoreUpdate, object: participantsStore)
        notificationCenter.addObserver(self, selector: #selector(handleMainParticipantStoreUpdate), name: .mainParticipantStoreUpdate, object: mainParticipantStore)
        notificationCenter.addObserver(self, selector: #selector(handleChatStoreUpdate), name: .chatStoreUpdate, object: chatStore)
    }
    
    func connect() {
        room.connect(roomName: roomName)
    }
    
    func disconnect() {
        room.disconnect()
    }
    
    func togglePin(at index: Int) {
        room.togglePin(participant: participantsStore.participants[index])
    }

    @objc private func handleRoomUpdate(_ notification: Notification) {
        guard let payload = notification.payload as? Room.Update else { return }
        
        switch payload {
        case .didStartConnecting:
            delegate?.didConnect()
        case let .didConnect(roomSID, accessToken):
            delegate?.didConnect()
            chatStore.connect(accessToken: accessToken, conversationName: roomSID)
        case let .didFailToConnect(error):
            delegate?.didFailToConnect(error: error)
        case let .didDisconnect(error):
            delegate?.didDisconnect(error: error)
        case .didStartRecording:
            delegate?.didUpdateRecording()
        case .didStopRecording:
            delegate?.didUpdateRecording()
        case .didAddRemoteParticipants, .didRemoveRemoteParticipants, .didUpdateParticipants:
            break
        }
    }

    @objc private func handleParticipansStoreUpdate(_ notification: Notification) {
        guard let payload = notification.payload as? ParticipantsStore.Update else { return }

        switch payload {
        case let .didUpdateList(diff): delegate?.didUpdateList(diff: diff)
        case let .didUpdateParticipant(index): delegate?.didUpdateParticipant(at: index)
        }
    }
    
    @objc private func handleMainParticipantStoreUpdate() {
        delegate?.didUpdateMainParticipant()
    }

    @objc private func handleChatStoreUpdate(_ notification: Notification) {
        guard let payload = notification.payload as? ChatStoreUpdate else { return }

        switch payload {
        case .didChangeConnectionState, .didChangeHasUnreadMessage: delegate?.didUpdateChat()
        case .didReceiveNewMessage: break
        }
    }
}
