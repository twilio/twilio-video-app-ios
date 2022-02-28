//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine

class RoomScreenViewModel: ObservableObject {
    enum State {
        case disconnected
        case connecting
        case connected
    }

    enum AlertIdentifier: String, Identifiable {
        case error
        
        var id: String { rawValue }
    }
    
    @Published var alertIdentifier: AlertIdentifier?
    @Published var state = State.disconnected
    private(set) var error: Error?
    private let accessTokenStore = TwilioAccessTokenStore()
    private var roomManager: RoomManager!
    private var subscriptions = Set<AnyCancellable>()

    func configure(roomManager: RoomManager) {
        self.roomManager = roomManager

        roomManager.roomConnectPublisher
            .sink { [weak self] in self?.state = .connected }
            .store(in: &subscriptions)

        roomManager.roomDisconnectPublisher
            .sink { [weak self] error in
                guard let error = error else {
                    return
                }
                
                self?.handleError(error)
            }
            .store(in: &subscriptions)
        
        roomManager.localParticipant.errorPublisher
            .sink { [weak self] error in self?.handleError(error) }
            .store(in: &subscriptions)
    }

    private func handleError(_ error: Error) {
        disconnect()
        self.error = error
        alertIdentifier = .error
    }

    func connect(roomName: String) {
        guard roomManager != nil else {
            return /// When not configured do nothing so `PreviewProvider` doesn't crash.
        }

        state = .connecting
        roomManager.localParticipant.isMicOn = true
        roomManager.localParticipant.isCameraOn = true

        Task {
            do {
                let accessToken = try await accessTokenStore.fetchTwilioAccessToken(roomName: roomName)
                roomManager.connect(roomName: roomName, accessToken: accessToken)
            } catch {
                handleError(error)
            }
        }
    }
    
    func disconnect() {
        roomManager.disconnect()
        state = .disconnected
        roomManager.localParticipant.isMicOn = false
        roomManager.localParticipant.isCameraOn = false
    }
}
