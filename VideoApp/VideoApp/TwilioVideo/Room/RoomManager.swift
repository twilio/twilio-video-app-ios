//
//  Copyright (C) 2022 Twilio, Inc.
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

import Combine
import TwilioVideo

/// Manages the video room connection and uses publishers to notify subscribers of state changes.
class RoomManager: NSObject, ObservableObject {
    // MARK: Publishers
    let roomConnectPublisher = PassthroughSubject<Void, Never>()
    let roomDisconnectPublisher = PassthroughSubject<Error?, Never>()
    let remoteParticipantConnectPublisher = PassthroughSubject<RemoteParticipantManager, Never>()
    let remoteParticipantDisconnectPublisher = PassthroughSubject<RemoteParticipantManager, Never>()

    /// Send remote participant updates from `RoomManager` instead of `RemoteParticipantManager` so that
    /// one publisher can provide updates for all remote participants. Otherwise subscribers would need to make
    /// subscription changes whenever a remote participant connects and disconnects.
    let remoteParticipantChangePublisher = PassthroughSubject<RemoteParticipantManager, Never>()
    // MARK: -

    @Published var isRecording = false
    @Published var room: Room? // Only exposed for stats
    private(set) var localParticipant: LocalParticipantManager!
    private(set) var remoteParticipants: [RemoteParticipantManager] = []

    func configure(localParticipant: LocalParticipantManager) {
        self.localParticipant = localParticipant
    }
    
    func connect(roomName: String, accessToken: String, uuid: UUID) {
        let options = ConnectOptionsFactory().makeConnectOptions(
            accessToken: accessToken,
            roomName: roomName,
            uuid: uuid,
            audioTracks: [localParticipant.micTrack].compactMap { $0 },
            videoTracks: [localParticipant.cameraTrack].compactMap { $0 }
        )

        room = TwilioVideoSDK.connect(options: options, delegate: self)
    }

    func disconnect() {
        cleanUp()
        roomDisconnectPublisher.send(nil) // Intentional disconnect so no error
    }
    
    private func cleanUp() {
        room?.disconnect()
        room = nil
        localParticipant.participant = nil
        remoteParticipants.removeAll()
        isRecording = false
    }
    
    private func handleError(_ error: Error) {
        cleanUp()
        roomDisconnectPublisher.send(error)
    }
}

extension RoomManager: RoomDelegate {
    func roomDidConnect(room: Room) {
        localParticipant.participant = room.localParticipant
        remoteParticipants = room.remoteParticipants
            .map { RemoteParticipantManager(participant: $0, delegate: self) }
        roomConnectPublisher.send()
    }
    
    func roomDidFailToConnect(room: Room, error: Error) {
        handleError(error)
    }
    
    func roomDidDisconnect(room: Room, error: Error?) {
        if let error = error {
            handleError(error)
        }
    }
    
    func participantDidConnect(room: Room, participant: RemoteParticipant) {
        let participant = RemoteParticipantManager(participant: participant, delegate: self)
        remoteParticipants.append(participant)
        remoteParticipantConnectPublisher.send(participant)
    }
    
    func participantDidDisconnect(room: Room, participant: RemoteParticipant) {
        guard let index = remoteParticipants.firstIndex(where: { $0.identity == participant.identity }) else {
            return
        }

        remoteParticipantDisconnectPublisher.send(remoteParticipants.remove(at: index))
    }

    func dominantSpeakerDidChange(room: Room, participant: RemoteParticipant?) {
        // Add dominant speaker state to participants so participants contain all
        // participant state. This is better for the UI.
        remoteParticipants.first { $0.isDominantSpeaker }?.isDominantSpeaker = false // Old speaker
        remoteParticipants.first { $0.identity == participant?.identity }?.isDominantSpeaker = true // New speaker
    }

    func roomDidStartRecording(room: TwilioVideo.Room) {
        isRecording = true
    }
    
    func roomDidStopRecording(room: TwilioVideo.Room) {
        isRecording = false
    }
}

extension RoomManager: RemoteParticipantManagerDelegate {
    func participantDidChange(_ participant: RemoteParticipantManager) {
        remoteParticipantChangePublisher.send(participant)
    }
}
