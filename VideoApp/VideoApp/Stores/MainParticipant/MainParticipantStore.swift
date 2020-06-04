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

import Foundation

class MainParticipantStore {
    private(set) var mainParticipant: Participant {
        didSet {
            videoTrack = mainParticipant.mainVideoTrack

            if mainParticipant.isPinned || videoTrack === mainParticipant.screenTrack || !mainParticipant.isDominantSpeaker {
                videoTrack?.priority = .high
            } else {
                videoTrack?.priority = nil
            }

            notificationCenter.post(name: .mainParticipantStoreUpdate, object: self)
        }
    }
    private(set) var videoTrack: VideoTrack? {
        didSet {
            guard oldValue !== videoTrack else { return }

            oldValue?.priority = nil
        }
    }
    private let room: Room
    private let participantsStore: ParticipantsStore
    private let notificationCenter: NotificationCenter
    
    init(room: Room, participantsStore: ParticipantsStore, notificationCenter: NotificationCenter) {
        self.room = room
        self.participantsStore = participantsStore
        self.notificationCenter = notificationCenter
        mainParticipant = room.localParticipant
        videoTrack = mainParticipant.mainVideoTrack
        update()
        notificationCenter.addObserver(self, selector: #selector(update), name: .roomUpdate, object: room)
        notificationCenter.addObserver(self, selector: #selector(update), name: .participantsStoreUpdate, object: participantsStore)
    }
    
    @objc private func update() {
        let pinnedParticipant = participantsStore.participants.first(where: { $0.isPinned })
        let screenParticipant = room.remoteParticipants.first(where: { $0.screenTrack != nil })
        let dominantSpeaker = room.remoteParticipants.first(where: { $0.isDominantSpeaker })
        let firstRemoteParticipant = participantsStore.participants.first(where: { $0.isRemote })
        
        mainParticipant =
            pinnedParticipant ??
            screenParticipant ??
            dominantSpeaker ??
            firstRemoteParticipant ??
            room.localParticipant
    }
}

private extension Participant {
    var mainVideoTrack: VideoTrack? { screenTrack ?? cameraTrack }
}
