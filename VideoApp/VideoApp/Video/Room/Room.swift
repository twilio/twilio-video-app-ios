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
        case didUpdateParticipants(participants: [Participant])
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
        super.init()
        localParticipant.delegate = self
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
    }
    
    func togglePin(participant new: Participant) {
        let allParticipants: [Participant] = [localParticipant] + remoteParticipants
        let old = allParticipants.first(where: { $0.isPinned })
        
        if let old = old, old !== new {
            old.isPinned = false
        }
        
        new.isPinned.toggle()
        post(.didUpdateParticipants(participants: [old, new].compactMap { $0 }))
    }
    
    private func post(_ update: Update) {
        notificationCenter.post(name: .roomUpdate, object: self, payload: update)
    }
}

extension Room: TwilioVideo.RoomDelegate {
    func roomDidConnect(room: TwilioVideo.Room) {
        localParticipant.participant = room.localParticipant
        remoteParticipants = room.remoteParticipants.map {
            RemoteParticipant(participant: $0, delegate: self)
        }
        state = .connected
        post(.didConnect)
        
        if !remoteParticipants.isEmpty {
            post(.didAddRemoteParticipants(participants: remoteParticipants))
        }
    }
    
    func roomDidFailToConnect(room: TwilioVideo.Room, error: Error) {
        state = .disconnected
        post(.didFailToConnect(error: error))
    }
    
    func roomDidDisconnect(room: TwilioVideo.Room, error: Error?) {
        localParticipant.participant = nil
        let participants = remoteParticipants
        remoteParticipants.removeAll()
        state = .disconnected
        post(.didDisconnect(error: error))
        
        if !remoteParticipants.isEmpty {
            post(.didRemoveRemoteParticipants(participants: participants))
        }
    }
    
    func participantDidConnect(room: TwilioVideo.Room, participant: TwilioVideo.RemoteParticipant) {
        remoteParticipants.append(RemoteParticipant(participant: participant, delegate: self))
    
        post(.didAddRemoteParticipants(participants: [remoteParticipants.last!]))
    }
    
    func participantDidDisconnect(room: TwilioVideo.Room, participant: TwilioVideo.RemoteParticipant) {
        guard let index = remoteParticipants.firstIndex(where: { $0.identity == participant.identity }) else { return }
        
        post(.didRemoveRemoteParticipants(participants: [remoteParticipants.remove(at: index)]))
    }
    
    func dominantSpeakerDidChange(room: TwilioVideo.Room, participant: TwilioVideo.RemoteParticipant?) {
        guard let new = remoteParticipants.first(where: { $0.identity == participant?.identity }) else { return }

        let old = remoteParticipants.first(where: { $0.isDominantSpeaker })
        old?.isDominantSpeaker = false
        new.isDominantSpeaker = true
        post(.didUpdateParticipants(participants: [old, new].compactMap { $0 }))
    }
}

extension Room: ParticipantDelegate {
    func didUpdate(participant: Participant) {
        post(.didUpdateParticipants(participants: [participant]))
    }
}
