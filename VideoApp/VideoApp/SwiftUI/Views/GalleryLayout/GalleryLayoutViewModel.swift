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

/// Manages gallery layout state changes.
///
/// The UI requires an array of pages in order to support pagination. Each page has an array of participants that can hold
/// up to the max number of participants per page. There is some special handling for the first page to display the most recent
/// dominant speakers and minimize ordering changes.
///
/// When a new participant connects to the video room they are added as the last participant on the last page.
///
/// When a participant that is not on the first page becomes dominant speaker they are moved to the position of the oldest
/// dominant speaker that is on the first page. The oldest dominant speaker on the first page is moved to the start of the second
/// page. Participants are then shifted across pages until all pages are full except possibly the last page.
///
/// When a participant is already on the first page and they become dominant speaker, the participant is updated in place
/// and there are no grid position changes.
///
/// When a participant on the first page disconnects from the video room, they are removed from the page. If there is more than
/// one page, the first participant on the second page is moved to the first page at the index where the participant was
/// disconnected. If there are more than two pages, participants are shifted left across pages until only the last page has less
/// than the max number of participants per page. This special handling for a participant that disconnects from the first page
/// minimizes ordering changes on the first page.
///
/// When a participant that is not on the first page disconnects from the video room, they are removed from the page. If the
/// participant was not on the last page, participants are shifted left across pages until only the last page has less
/// than the max number of participants per page.
///
/// Some participant state, such as mute status, does not impact grid ordering. The participant will be updated in place so the
/// UI can update the view for that participant.
class GalleryLayoutViewModel: ObservableObject {
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
            /// Special case to minimize ordering changes on the first page
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

        if indexPath.section == 0 {
            pages[indexPath.section].participants[indexPath.item] = participant
        } else {
            pages[indexPath.section].participants[indexPath.item] = participant

            if participant.isDominantSpeaker {
                /// Always keep the most recent dominant speakers on the first page
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

/// Handles CRUD operations for participants that are distributed across multiple pages.
///
/// The operations ensure that participants are shifted across pages as necessary so that all pages are full except possibly
/// the last page.
///
/// The solution is recursive to keep things as simple as possible. There should not be any performance issues because
/// a video room does not allow a massive number of participants to be connected.
private extension Array where Element == GalleryLayoutViewModel.Page {
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
            let newPage = GalleryLayoutViewModel.Page(identifier: endIndex, participants: [participant])
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
            let newPage = GalleryLayoutViewModel.Page(identifier: indexPath.section, participants: [participant])
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
            let newPage = GalleryLayoutViewModel.Page(
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
