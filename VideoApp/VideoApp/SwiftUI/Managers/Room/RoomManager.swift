//
//  Copyright (C) 2020 Twilio, Inc.
//

import Combine
import TwilioVideo

/// Configures the video room connection and uses publishers to notify subscribers of state changes.
class RoomManager: NSObject {
    // MARK: Publishers
    let roomConnectPublisher = PassthroughSubject<Void, Never>()
    let roomDisconnectPublisher = PassthroughSubject<Error?, Never>()
    let remoteParticipantConnectPublisher = PassthroughSubject<RemoteParticipantManager, Never>()
    let remoteParticipantDisconnectPublisher = PassthroughSubject<RemoteParticipantManager, Never>()

    /// Send remote participant updates from `RoomManager` instead of `RemoteParticipantManager` so that
    /// one publisher can provide updates for all remote participants. Otherwise subscribers would need to make
    /// subscription changes whenever a remote participant connects or disconnects.
    let remoteParticipantChangePublisher = PassthroughSubject<RemoteParticipantManager, Never>()
    // MARK: -

    var roomSID: String? { room?.sid }
    var roomName: String? { room?.name }
    private(set) var localParticipant: LocalParticipantManager!
    private(set) var remoteParticipants: [RemoteParticipantManager] = []
    private var room: Room?

    func configure(localParticipant: LocalParticipantManager) {
        self.localParticipant = localParticipant
    }
    
    func connect(roomName: String, accessToken: String) {
        let connectOptionsFactory = ConnectOptionsFactory()
        
        let options = connectOptionsFactory.makeConnectOptions(
            accessToken: accessToken,
            roomName: roomName,
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
        guard let index = remoteParticipants.firstIndex(where: { $0.identity == participant.identity }) else { return }

        remoteParticipantDisconnectPublisher.send(remoteParticipants.remove(at: index))
    }

    func dominantSpeakerDidChange(room: Room, participant: RemoteParticipant?) {
        // Add dominant speaker state to participants so participants contain all
        // participant state. This is better for the UI.
        remoteParticipants.first { $0.isDominantSpeaker }?.isDominantSpeaker = false // Old speaker
        remoteParticipants.first { $0.identity == participant?.identity }?.isDominantSpeaker = true // New speaker
    }
}

extension RoomManager: RemoteParticipantManagerDelegate {
    func participantDidChange(_ participant: RemoteParticipantManager) {
        remoteParticipantChangePublisher.send(participant)
    }
}
