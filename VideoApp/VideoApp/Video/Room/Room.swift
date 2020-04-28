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

import TwilioVideo

@objc class Room: NSObject {
    enum Update {
        case didStartConnecting
        case didConnect
        case didFailToConnect(error: Error)
        case didDisconnect(error: Error?)
        case didAddRemoteParticipants(participants: [Participant])
        case didRemoveRemoteParticipants(participants: [Participant])
    }

    let localParticipant: LocalParticipant
    private(set) var remoteParticipants: [RemoteParticipant] = []
    private(set) var state: RoomState = .disconnected
    @objc private(set) var room: TwilioVideo.Room? // Only exposed for stats and should not be used for anything else
    private let accessTokenStore: TwilioAccessTokenStoreReading
    private let connectOptionsFactory: ConnectOptionsFactory
    private let notificationCenter: NotificationCenter
    private let twilioVideoSDKType: TwilioVideoSDK.Type
    
    init(
        localParticipant: LocalParticipant,
        accessTokenStore: TwilioAccessTokenStoreReading,
        connectOptionsFactory: ConnectOptionsFactory,
        notificationCenter: NotificationCenter,
        twilioVideoSDKType: TwilioVideoSDK.Type
    ) {
        self.localParticipant = localParticipant
        self.accessTokenStore = accessTokenStore
        self.connectOptionsFactory = connectOptionsFactory
        self.notificationCenter = notificationCenter
        self.twilioVideoSDKType = twilioVideoSDKType
    }

    func connect(roomName: String) {
        guard state == .disconnected else { fatalError("Connection already in progress.") }

        state = .connecting
        post(.didStartConnecting)

        accessTokenStore.fetchTwilioAccessToken(roomName: roomName) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(accessToken):
                let options = self.connectOptionsFactory.makeConnectOptions(
                    accessToken: accessToken,
                    roomName: roomName,
                    audioTracks: [self.localParticipant.micTrack].compactMap { $0 },
                    videoTracks: [self.localParticipant.localCameraTrack].compactMap { $0 }
                )
                self.room = self.twilioVideoSDKType.connect(options: options, delegate: self)
            case let .failure(error):
                self.state = .disconnected
                self.post(.didFailToConnect(error: error))
            }
        }
    }

    func disconnect() {
        room?.disconnect()
        state = .disconnected
        post(.didDisconnect(error: nil))
    }
    
    private func updateRemoteParticipants() {
        guard let room = room else { remoteParticipants = []; return }
        
        remoteParticipants = room.remoteParticipants.map { RemoteParticipant(participant: $0, notificationCenter: .default) }
    }
    
    private func post(_ update: Update) {
        notificationCenter.post(name: .roomUpdate, object: self, payload: update)
    }
}

extension Room: TwilioVideo.RoomDelegate {
    func roomDidConnect(room: TwilioVideo.Room) {
        localParticipant.participant = room.localParticipant
        updateRemoteParticipants()
        state = .connected
        post(.didConnect)
        
        if !remoteParticipants.isEmpty {
            post(.didAddRemoteParticipants(participants: remoteParticipants))
        }
    }
    
    func roomDidFailToConnect(room: TwilioVideo.Room, error: Error) {
        self.room = nil
        state = .disconnected
        post(.didFailToConnect(error: error))
    }
    
    func roomDidDisconnect(room: TwilioVideo.Room, error: Error?) {
        self.room = nil
        localParticipant.participant = nil
        let participants = remoteParticipants
        updateRemoteParticipants()
        state = .disconnected
        post(.didDisconnect(error: error))
        
        if !remoteParticipants.isEmpty {
            post(.didRemoveRemoteParticipants(participants: participants))
        }
    }
    
    func participantDidConnect(room: TwilioVideo.Room, participant: TwilioVideo.RemoteParticipant) {
        updateRemoteParticipants()
    
        post(.didAddRemoteParticipants(participants: [remoteParticipants[remoteParticipants.count - 1]]))
    }
    
    func participantDidDisconnect(room: TwilioVideo.Room, participant: TwilioVideo.RemoteParticipant) {
        guard let participant = remoteParticipants.first(identity: participant.identity) else { return }
        
        updateRemoteParticipants()
        post(.didRemoveRemoteParticipants(participants: [participant]))
    }
    
    func dominantSpeakerDidChange(room: TwilioVideo.Room, participant: TwilioVideo.RemoteParticipant?) {
        guard let participant = remoteParticipants.first(identity: participant?.identity) else { return }

        remoteParticipants.first(where: { $0.isDominantSpeaker })?.isDominantSpeaker = false
        participant.isDominantSpeaker = true // The participant sends out update
    }
}

private extension Array where Element == RemoteParticipant {
    func first(identity: String?) -> RemoteParticipant? {
        first(where: { $0.identity == identity })
    }
}
