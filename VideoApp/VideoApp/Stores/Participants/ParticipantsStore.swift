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

import IGListDiffKit

class ParticipantsStore {
    enum Update {
        case didUpdateParticipant(index: Int)
        case didUpdateList(diff: ListIndexSetResult)
    }

    private(set) var participants: [Participant] = []
    private let room: Room
    private let notificationCenter: NotificationCenter
    
    init(room: Room, notificationCenter: NotificationCenter) {
        self.room = room
        self.notificationCenter = notificationCenter
        insert(participants: [room.localParticipant] + room.remoteParticipants)
        notificationCenter.addObserver(self, selector: #selector(handleRoomUpdate(_:)), name: .roomUpdate, object: room)
    }

    @objc private func handleRoomUpdate(_ notification: Notification) {
        guard let payload = notification.payload as? Room.Update else { return }
        
        switch payload {
        case .didStartConnecting, .didConnect, .didFailToConnect, .didDisconnect, .didStartRecording, .didStopRecording: break
        case let .didAddRemoteParticipants(participants): insert(participants: participants)
        case let .didRemoveRemoteParticipants(participants): delete(participants: participants)
        case let .didUpdateParticipants(participants): update(participants: participants)
        }
    }

    private func insert(participants: [Participant]) {
        var new = self.participants
        
        participants.forEach { participant in
            let index: Int
            
            if !participant.isRemote {
                index = 0
            } else if participant.isDominantSpeaker {
                index = new.dominantSpeakerIndex
            } else {
                index = new.endIndex
            }
            
            new.insert(participant, at: index)
        }
        
        postDiff(new: new)
    }
    
    private func delete(participants: [Participant]) {
        let new = self.participants.filter { participant in
            participants.first { $0 === participant } == nil
        }

        postDiff(new: new)
    }

    private func update(participants: [Participant]) {
        participants.forEach { participant in
            guard let index = self.participants.firstIndex(where: { $0 === participant }) else { return }
            
            post(.didUpdateParticipant(index: index))
            
            if participant.isDominantSpeaker && index != self.participants.dominantSpeakerIndex {
                var new = self.participants
                new.remove(at: index)
                new.insert(participant, at: new.dominantSpeakerIndex)
                postDiff(new: new)
            }
        }
    }

    private func postDiff(new: [Participant]) {
        let diff = ListDiff(oldArray: self.participants, newArray: new, option: .equality)
        self.participants = new
        post(.didUpdateList(diff: diff))
    }

    private func post(_ update: Update) {
        notificationCenter.post(name: .participantsStoreUpdate, object: self, payload: update)
    }
}

private extension Array where Element == Participant {
    var dominantSpeakerIndex: Int { firstIndex(where: { $0.isRemote }) ?? endIndex }
}
