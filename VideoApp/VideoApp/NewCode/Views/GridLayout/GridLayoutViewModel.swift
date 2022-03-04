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

import TwilioVideo
import Combine

/// Subscribes to room and participant state changes to provide participant state for the UI to display in a grid.
class GridLayoutViewModel: ObservableObject {
    struct Page: Hashable {
        let identifier: Int
        var participants: [ParticipantViewModel]

        func indexOf(identity: String) -> Int? {
            participants.firstIndex { $0.identity == identity }
        }

        static func == (lhs: Page, rhs: Page) -> Bool {
            lhs.identifier == rhs.identifier
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }

    @Published var pages: [Page] = []
    private let maxParticipantsPerPage = 6
    private var roomManager: RoomManager!
    private var subscriptions = Set<AnyCancellable>()

    func configure(roomManager: RoomManager) {
        self.roomManager = roomManager
        
        roomManager.roomConnectPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                
                self.addParticipant(ParticipantViewModel(participant: self.roomManager.localParticipant))

                self.roomManager.remoteParticipants
                    .map { ParticipantViewModel(participant: $0) }
                    .forEach { self.addParticipant($0) }
            }
            .store(in: &subscriptions)
        
        roomManager.roomDisconnectPublisher
            .sink { [weak self] _ in
                self?.pages.removeAll()
            }
            .store(in: &subscriptions)

        roomManager.localParticipant.changePublisher
            .sink { [weak self] participant in
                guard let self = self, !self.pages.isEmpty else { return }
                
                self.pages[0].participants[0] = ParticipantViewModel(participant: participant)
            }
            .store(in: &subscriptions)

        roomManager.remoteParticipantConnectPublisher
            .sink { [weak self] participant in
                guard let self = self else { return }

                self.addParticipant(ParticipantViewModel(participant: participant)) }
            .store(in: &subscriptions)

        roomManager.remoteParticipantDisconnectPublisher
            .sink { [weak self] participant in self?.removeParticipant(with: participant.identity) }
            .store(in: &subscriptions)

        roomManager.remoteParticipantChangePublisher
            .sink { [weak self] participant in
                guard let self = self else { return }

                self.updateParticipant(ParticipantViewModel(participant: participant)) }
            .store(in: &subscriptions)
    }
    
    private func addParticipant(_ participant: ParticipantViewModel) {
        if !pages.isEmpty && pages.last!.participants.count < maxParticipantsPerPage {
            pages[pages.count - 1].participants.append(participant)
        } else {
            let page = Page(identifier: pages.count, participants: [participant])
            pages.append(page)
        }
    }
    
    private func removeParticipant(with identity: String) {
        guard let indexPath = pages.IndexPathForParticipant(identity: identity) else {
            return
        }
        
        pages.removeParticipant(at: indexPath)
    }

    private func updateParticipant(_ participant: ParticipantViewModel) {
        guard let indexPath = pages.IndexPathForParticipant(identity: participant.identity) else {
            return
        }

        if indexPath.section == .zero {
            pages[indexPath.section].participants[indexPath.item] = participant
        } else {
            pages[indexPath.section].participants[indexPath.item] = participant

            // If an offscreen participant becomes dominant speaker move them to onscreen participants.
            // The oldest dominant speaker that is onscreen is moved to the start of offscreen participants.
            // The new dominant speaker is moved onscreen where the oldest dominant speaker was located.
            // This approach always keeps the most recent dominant speakers visible.
            if participant.isDominantSpeaker {
                let oldestDominantSpeaker = pages[0].participants[1...] // Skip local user at 0
                    .sorted { $0.dominantSpeakerStartTime < $1.dominantSpeakerStartTime }
                    .first!

                let oldestDominantSpeakerIndex = pages[0].participants.firstIndex(of: oldestDominantSpeaker)!

                pages.removeParticipant(at: IndexPath(item: oldestDominantSpeakerIndex, section: 0))
                pages.insertParticipant(participant, at: IndexPath(item: oldestDominantSpeakerIndex, section: 0))
                pages.removeParticipant(at: indexPath)
                pages.insertParticipant(oldestDominantSpeaker, at: IndexPath(item: 0, section: 1))
            }
        }
    }
}

extension Array where Element == GridLayoutViewModel.Page {
    func IndexPathForParticipant(identity: String) -> IndexPath? {
        guard
            let pageIndex = firstIndex(where: { $0.indexOf(identity: identity) != nil }),
            let participantIndex = self[pageIndex].indexOf(identity: identity)
        else {
            return nil
        }
        
        return IndexPath(item: participantIndex, section: pageIndex)
    }
    
    mutating func removeParticipant(at indexPath: IndexPath) {
        self[indexPath.section].participants.remove(at: indexPath.item)
        
        shiftForward(pageIndex: indexPath.section)
    }
    
    mutating func shiftForward(pageIndex: Int) {
        if pageIndex == count - 1 {
            // Last page
            if self[pageIndex].participants.isEmpty {
                remove(at: pageIndex)
            }
        } else {
            self[pageIndex].participants.append(self[pageIndex + 1].participants.removeFirst())
            shiftForward(pageIndex: pageIndex + 1)
        }
    }

    mutating func insertParticipant(_ participant: ParticipantViewModel, at indexPath: IndexPath) {
        if indexPath.section > count - 1 {
            let newPage = GridLayoutViewModel.Page(identifier: indexPath.section, participants: [participant])
            append(newPage)
        } else {
            self[indexPath.section].participants.insert(participant, at: indexPath.item)
            shiftRight(pageIndex: indexPath.section)
        }
    }
    
    mutating func shiftRight(pageIndex: Int) {
        if self[pageIndex].participants.count > 6 {
            if pageIndex == count - 1 {
                let newPage = GridLayoutViewModel.Page(identifier: pageIndex + 1, participants: [self[pageIndex].participants.removeLast()])
                append(newPage)
            } else {
                self[pageIndex + 1].participants.insert(self[pageIndex].participants.last!, at: 0)
                shiftRight(pageIndex: pageIndex + 1)
            }
        }
    }
}
