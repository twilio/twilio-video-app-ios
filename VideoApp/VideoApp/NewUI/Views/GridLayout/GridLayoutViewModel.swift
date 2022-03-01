//
//  Copyright (C) 2021 Twilio, Inc.
//

import TwilioVideo
import Combine

/// Subscribes to room and participant state changes to provide participant state for the UI to display in a grid
class GridLayoutViewModel: ObservableObject {
    @Published var onscreenParticipants: [ParticipantViewModel] = []
    @Published var offscreenParticipants: [ParticipantViewModel] = []
    private let maxOnscreenParticipantCount = 6
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
                self?.onscreenParticipants.removeAll()
                self?.offscreenParticipants.removeAll()
            }
            .store(in: &subscriptions)

        roomManager.localParticipant.changePublisher
            .sink { [weak self] participant in
                guard let self = self, !self.onscreenParticipants.isEmpty else { return }
                
                self.onscreenParticipants[0] = ParticipantViewModel(participant: participant)
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
        if onscreenParticipants.count < maxOnscreenParticipantCount {
            onscreenParticipants.append(participant)
        } else {
            offscreenParticipants.append(participant)
        }
    }
    
    private func removeParticipant(with identity: String) {
        if let index = onscreenParticipants.firstIndex(where: { $0.identity == identity }) {
            onscreenParticipants.remove(at: index)
            
            if !offscreenParticipants.isEmpty {
                onscreenParticipants.append(offscreenParticipants.removeFirst())
            }
        } else {
            offscreenParticipants.removeAll { $0.identity == identity }
        }
    }

    private func updateParticipant(_ participant: ParticipantViewModel) {
        if let index = onscreenParticipants.firstIndex(of: participant) {
            onscreenParticipants[index] = participant
        } else if let index = offscreenParticipants.firstIndex(of: participant) {
            offscreenParticipants[index] = participant

            // If an offscreen participant becomes dominant speaker move them to onscreen participants.
            // The oldest dominant speaker that is onscreen is moved to the start of offscreen participants.
            // The new dominant speaker is moved onscreen where the oldest dominant speaker was located.
            // This approach always keeps the most recent dominant speakers visible.
            if participant.isDominantSpeaker {
                let oldestDominantSpeaker = onscreenParticipants[1...] // Skip local user at 0
                    .sorted { $0.dominantSpeakerStartTime < $1.dominantSpeakerStartTime }
                    .first!
                
                let oldestDominantSpeakerIndex = onscreenParticipants.firstIndex(of: oldestDominantSpeaker)!
                
                onscreenParticipants.remove(at: oldestDominantSpeakerIndex)
                onscreenParticipants.insert(participant, at: oldestDominantSpeakerIndex)
                offscreenParticipants.remove(at: index)
                offscreenParticipants.insert(oldestDominantSpeaker, at: 0)
            }
        }
    }
}
