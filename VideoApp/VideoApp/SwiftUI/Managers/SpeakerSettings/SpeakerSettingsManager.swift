//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine
import Foundation

class SpeakerSettingsManager: ObservableObject {
    @Published var isMicOn = false {
        didSet {
            guard oldValue != isMicOn else { return }
            
            roomManager.localParticipant.isMicOn = isMicOn
        }
    }
    @Published var isCameraOn = false {
        didSet {
            guard oldValue != isCameraOn else { return }

            roomManager.localParticipant.isCameraOn = isCameraOn
        }
    }
    private var roomManager: RoomManager!
    private var subscriptions = Set<AnyCancellable>()
    
    func configure(roomManager: RoomManager) {
        self.roomManager = roomManager
        
        roomManager.localParticipant.changePublisher
            .sink { [weak self] participant in
                self?.isMicOn = participant.isMicOn
                self?.isCameraOn = participant.isCameraOn
            }
            .store(in: &subscriptions)
    }
}
