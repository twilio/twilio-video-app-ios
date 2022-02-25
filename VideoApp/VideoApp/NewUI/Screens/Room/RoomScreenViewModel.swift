//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine

class RoomScreenViewModel: ObservableObject {
    enum AlertIdentifier: String, Identifiable {
        case error
        
        var id: String { rawValue }
    }
    
    @Published var alertIdentifier: AlertIdentifier?
    private(set) var error: Error?
    private var streamManager: StreamManager!
    private var speakerSettingsManager: SpeakerSettingsManager!
    private var subscriptions = Set<AnyCancellable>()

    func configure(streamManager: StreamManager, speakerSettingsManager: SpeakerSettingsManager) {
        self.streamManager = streamManager
        self.speakerSettingsManager = speakerSettingsManager

        streamManager.$state
            .sink { [weak self] state in
                guard let self = self, streamManager.config != nil else {
                    return
                }
                
                switch state {
                case .connecting:
                    self.speakerSettingsManager.isMicOn = true
                    self.speakerSettingsManager.isCameraOn = true
                case .disconnected:
                    self.speakerSettingsManager.isMicOn = false
                    self.speakerSettingsManager.isCameraOn = false
                case .connected:
                    break
                }
            }
            .store(in: &subscriptions)

        streamManager.errorPublisher
            .sink { [weak self] error in self?.handleError(error) }
            .store(in: &subscriptions)
    }

    private func handleError(_ error: Error) {
        streamManager.disconnect()
        self.error = error
        alertIdentifier = .error
    }
}
