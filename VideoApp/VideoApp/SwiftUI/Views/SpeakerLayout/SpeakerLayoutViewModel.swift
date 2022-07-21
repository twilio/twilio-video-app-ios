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

class SpeakerLayoutViewModel: ObservableObject {
    struct Presenter {
        var identity: String = ""
        var presentationTrack: VideoTrack?
    }

    @Published var isPresenting = false
    @Published var presenter = Presenter()
    @Published var dominantSpeaker = ParticipantViewModel()
    private var roomManager: RoomManager!
    private var subscriptions = Set<AnyCancellable>()

    func configure(roomManager: RoomManager) {
        self.roomManager = roomManager
        
        roomManager.roomConnectPublisher
            .sink { [weak self] in self?.update() }
            .store(in: &subscriptions)
        
        roomManager.roomDisconnectPublisher
            .sink { [weak self] _ in self?.update() }
            .store(in: &subscriptions)

        roomManager.remoteParticipantConnectPublisher
            .sink { [weak self] _ in self?.update() }
            .store(in: &subscriptions)

        roomManager.remoteParticipantDisconnectPublisher
            .sink { [weak self] _ in self?.update() }
            .store(in: &subscriptions)

        roomManager.remoteParticipantChangePublisher
            .sink { [weak self] _ in self?.update() }
            .store(in: &subscriptions)
    }

    private func update() {
        dominantSpeaker = findDominantSpeaker()
        dominantSpeaker.isDominantSpeaker = false // No need to distinguish in the UI since only 1 participant is shown

        if let presenter = findPresenter() {
            self.presenter = presenter

            if !isPresenting {
                isPresenting = true
            }
        } else {
            presenter = Presenter()
            
            if isPresenting {
                isPresenting = false
            }
        }
    }
    
    private func findPresenter() -> Presenter? {
        guard let presenter = roomManager.remoteParticipants.first(where: { $0.presentationTrack != nil }) else {
            return nil
        }
        
        return Presenter(identity: presenter.identity, presentationTrack: presenter.presentationTrack!)
    }
    
    private func findDominantSpeaker() -> ParticipantViewModel {
        if let activeDominantSpeaker = roomManager.remoteParticipants.first(where: { $0.isDominantSpeaker }) {
            // There is an active dominant speaker
            return ParticipantViewModel(participant: activeDominantSpeaker)
        } else if let previousDominantSpeaker = roomManager.remoteParticipants.first(where: { $0.identity == dominantSpeaker.identity }) {
            // The previous dominant speaker is still connected so use them
            return ParticipantViewModel(participant: previousDominantSpeaker)
        } else {
            // Dominant speaker is not yet known or the previous dominant speaker disconnected
            if let firstRemoteParticipant = roomManager.remoteParticipants.first {
                // Keep it simple and just use first remote participant because someone will start talking soon
                return ParticipantViewModel(participant: firstRemoteParticipant)
            } else {
                // Use local participant
                return ParticipantViewModel(participant: roomManager.localParticipant)
            }
        }
    }
}
