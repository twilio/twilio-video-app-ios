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

/// Subscribes to room and participant state changes to provide participant state for the UI to display in a grid.
class GridLayoutViewModel: ObservableObject {
    struct Page: Hashable {
        let identifier: Int
        var participants: [ParticipantViewModel]

        static func == (lhs: Page, rhs: Page) -> Bool {
            lhs.identifier == rhs.identifier
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }

    @Published var pages: [Page] = []
    let maxParticipantsPerPage = 6
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

                self.addParticipant(ParticipantViewModel(participant: participant))
            }
            .store(in: &subscriptions)

        roomManager.remoteParticipantDisconnectPublisher
            .sink { [weak self] participant in self?.removeParticipant(identity: participant.identity) }
            .store(in: &subscriptions)

        roomManager.remoteParticipantChangePublisher
            .sink { [weak self] participant in
                guard let self = self else { return }
                
                self.updateParticipant(ParticipantViewModel(participant: participant))
            }
            .store(in: &subscriptions)
    }
    
    func addParticipant(_ participant: ParticipantViewModel) {
        pages.appendParticipant(participant, maxParticipantsPerPage: maxParticipantsPerPage)
    }
    
    func removeParticipant(identity: String) {
        guard let indexPath = pages.indexPathOfParticipant(identity: identity) else {
            return
        }
        
        if indexPath.section == 0 && pages.count > 1 {
            /// Handle special case to minimize changes to first page
            pages.removeParticipant(at: indexPath, shouldShift: false)
            pages.insertParticipant(
                pages[1].participants[0],
                at: indexPath,
                maxParticipantsPerPage: maxParticipantsPerPage,
                shouldShift: false
            )
            pages.removeParticipant(at: IndexPath(item: 0, section: 1))
        } else {
            pages.removeParticipant(at: indexPath)
        }
    }

    func updateParticipant(_ participant: ParticipantViewModel) {
        guard let indexPath = pages.indexPathOfParticipant(identity: participant.identity) else {
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
                let oldestDominantSpeakerIndexPath = IndexPath(
                    item: pages[0].participants.firstIndex(of: oldestDominantSpeaker)!,
                    section: 0
                )
                pages.removeParticipant(at: oldestDominantSpeakerIndexPath, shouldShift: false)
                pages.insertParticipant(
                    participant,
                    at: oldestDominantSpeakerIndexPath,
                    maxParticipantsPerPage: maxParticipantsPerPage,
                    shouldShift: false
                )
                pages.removeParticipant(at: indexPath)
                pages.insertParticipant(
                    oldestDominantSpeaker,
                    at: IndexPath(item: 0, section: 1),
                    maxParticipantsPerPage: maxParticipantsPerPage
                )
            }
        }
    }
}

// TODO: Explain recursive solution.
private extension Array where Element == GridLayoutViewModel.Page {
    func indexPathOfParticipant(identity: String) -> IndexPath? {
        for (section, page) in enumerated() {
            for (item, participant) in page.participants.enumerated() {
                if participant.identity == identity {
                    return IndexPath(item: item, section: section)
                }
            }
        }
        
        return nil
    }

    mutating func appendParticipant(_ participant: ParticipantViewModel, maxParticipantsPerPage: Int) {
        if !isEmpty && last!.participants.count < maxParticipantsPerPage {
            self[endIndex - 1].participants.append(participant)
        } else {
            let newPage = GridLayoutViewModel.Page(identifier: endIndex, participants: [participant])
            append(newPage)
        }
    }
    
    mutating func insertParticipant(
        _ participant: ParticipantViewModel,
        at indexPath: IndexPath,
        maxParticipantsPerPage: Int,
        shouldShift: Bool = true
    ) {
        if indexPath.section == endIndex {
            let newPage = GridLayoutViewModel.Page(identifier: indexPath.section, participants: [participant])
            append(newPage)
        } else {
            self[indexPath.section].participants.insert(participant, at: indexPath.item)
            
            if shouldShift {
                shiftRight(pageIndex: indexPath.section, maxParticipantsPerPage: maxParticipantsPerPage)
            }
        }
    }

    mutating func removeParticipant(at indexPath: IndexPath, shouldShift: Bool = true) {
        self[indexPath.section].participants.remove(at: indexPath.item)
        
        if shouldShift {
            shiftLeft(pageIndex: indexPath.section)
        }
    }

    private mutating func shiftLeft(pageIndex: Int) {
        if pageIndex < endIndex - 1 {
            self[pageIndex].participants.append(self[pageIndex + 1].participants.removeFirst())
            shiftLeft(pageIndex: pageIndex + 1)
        } else if self[pageIndex].participants.isEmpty {
            // If the last page is empty remove it
            remove(at: pageIndex)
        }
    }
    
    private mutating func shiftRight(pageIndex: Int, maxParticipantsPerPage: Int) {
        guard self[pageIndex].participants.count > maxParticipantsPerPage else {
            return
        }
        
        if pageIndex == endIndex - 1 {
            let newPage = GridLayoutViewModel.Page(
                identifier: pageIndex + 1,
                participants: [self[pageIndex].participants.removeLast()]
            )
            append(newPage)
        } else {
            self[pageIndex + 1].participants.insert(self[pageIndex].participants.removeLast(), at: 0)
            shiftRight(pageIndex: pageIndex + 1, maxParticipantsPerPage: maxParticipantsPerPage)
        }
    }
}
