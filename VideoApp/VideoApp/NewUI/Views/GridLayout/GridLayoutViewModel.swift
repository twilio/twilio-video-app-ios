//
//  Copyright (C) 2021 Twilio, Inc.
//

import TwilioVideo
import Combine

/// Subscribes to room and participant state changes to provide speaker state for the UI to display in a grid
class GridLayoutViewModel: ObservableObject {
    @Published var onscreenSpeakers: [ParticipantViewModel] = []
    @Published var offscreenSpeakers: [ParticipantViewModel] = []
    private let maxOnscreenSpeakerCount = 6
    private var roomManager: RoomManager!
    private var subscriptions = Set<AnyCancellable>()

    func configure(roomManager: RoomManager) {
        self.roomManager = roomManager
        
        roomManager.roomConnectPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                
                self.addSpeaker(ParticipantViewModel(participant: self.roomManager.localParticipant))

                self.roomManager.remoteParticipants
                    .map { ParticipantViewModel(participant: $0) }
                    .forEach { self.addSpeaker($0) }
            }
            .store(in: &subscriptions)
        
        roomManager.roomDisconnectPublisher
            .sink { [weak self] _ in
                self?.onscreenSpeakers.removeAll()
                self?.offscreenSpeakers.removeAll()
            }
            .store(in: &subscriptions)

        roomManager.localParticipant.changePublisher
            .sink { [weak self] participant in
                guard let self = self, !self.onscreenSpeakers.isEmpty else { return }
                
                self.onscreenSpeakers[0] = ParticipantViewModel(participant: participant)
            }
            .store(in: &subscriptions)

        roomManager.remoteParticipantConnectPublisher
            .sink { [weak self] participant in
                guard let self = self else { return }

                self.addSpeaker(ParticipantViewModel(participant: participant)) }
            .store(in: &subscriptions)

        roomManager.remoteParticipantDisconnectPublisher
            .sink { [weak self] participant in self?.removeSpeaker(with: participant.identity) }
            .store(in: &subscriptions)

        roomManager.remoteParticipantChangePublisher
            .sink { [weak self] participant in
                guard let self = self else { return }

                self.updateSpeaker(ParticipantViewModel(participant: participant)) }
            .store(in: &subscriptions)
    }
    
    private func addSpeaker(_ speaker: ParticipantViewModel) {
        if onscreenSpeakers.count < maxOnscreenSpeakerCount {
            onscreenSpeakers.append(speaker)
        } else {
            offscreenSpeakers.append(speaker)
        }
    }
    
    private func removeSpeaker(with identity: String) {
        if let index = onscreenSpeakers.firstIndex(where: { $0.identity == identity }) {
            onscreenSpeakers.remove(at: index)
            
            if !offscreenSpeakers.isEmpty {
                onscreenSpeakers.append(offscreenSpeakers.removeFirst())
            }
        } else {
            offscreenSpeakers.removeAll { $0.identity == identity }
        }
    }

    private func updateSpeaker(_ speaker: ParticipantViewModel) {
        if let index = onscreenSpeakers.firstIndex(of: speaker) {
            onscreenSpeakers[index] = speaker
        } else if let index = offscreenSpeakers.firstIndex(of: speaker) {
            offscreenSpeakers[index] = speaker

            // If an offscreen speaker becomes dominant speaker move them to onscreen speakers.
            // The oldest dominant speaker that is onscreen is moved to the start of offscreen users.
            // The new dominant speaker is moved onscreen where the oldest dominant speaker was located.
            // This approach always keeps the most recent dominant speakers visible.
            if speaker.isDominantSpeaker {
                let oldestDominantSpeaker = onscreenSpeakers[1...] // Skip local user at 0
                    .sorted { $0.dominantSpeakerStartTime < $1.dominantSpeakerStartTime }
                    .first!
                
                let oldestDominantSpeakerIndex = onscreenSpeakers.firstIndex(of: oldestDominantSpeaker)!
                
                onscreenSpeakers.remove(at: oldestDominantSpeakerIndex)
                onscreenSpeakers.insert(speaker, at: oldestDominantSpeakerIndex)
                offscreenSpeakers.remove(at: index)
                offscreenSpeakers.insert(oldestDominantSpeaker, at: 0)
            }
        }
    }
}
