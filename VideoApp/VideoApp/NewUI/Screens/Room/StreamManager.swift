//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine

/// Connects to a stream and can reconnect as speaker or viewer to change role.
///
/// Internally coordinates `RoomManager`, `PlayerManager`, and `SyncManager` connections.
class StreamManager: ObservableObject {
    enum State {
        case disconnected
        case connecting
        case connected
    }

    let errorPublisher = PassthroughSubject<Error, Never>()
    @Published var state = State.disconnected
    var config: StreamConfig!
    private var roomManager: RoomManager!
    private var accessTokenStore: TwilioAccessTokenStore!
    private var subscriptions = Set<AnyCancellable>()

    func configure(roomManager: RoomManager) {
        self.roomManager = roomManager
        
        // TODO: Move?
        accessTokenStore = TwilioAccessTokenStore(
            api: API.shared,
            appSettingsStore: AppSettingsStore.shared,
            authStore: AuthStore.shared,
            remoteConfigStore: RemoteConfigStoreFactory().makeRemoteConfigStore()
        )
        
        roomManager.roomConnectPublisher
            .sink { [weak self] in self?.state = .connected }
            .store(in: &subscriptions)

        roomManager.roomDisconnectPublisher
            .sink { [weak self] error in
                guard let error = error else { return }
                
                self?.handleError(error)
            }
            .store(in: &subscriptions)
        
        roomManager.localParticipant.errorPublisher
            .sink { [weak self] error in self?.handleError(error) }
            .store(in: &subscriptions)
    }
    
    func connect() {
        guard roomManager != nil else {
            return /// When not configured do nothing so `PreviewProvider` doesn't crash.
        }

        state = .connecting
        fetchAccessToken()
    }
    
    func disconnect() {
        roomManager.disconnect()
        state = .disconnected
    }
    
    private func fetchAccessToken() {
        accessTokenStore.fetchTwilioAccessToken(roomName: config.streamName) { [weak self] result in
            switch result {
            case let .success(accessToken):
                self?.connectRoomOrPlayer(accessToken: accessToken)
            case let .failure(error):
                self?.handleError(error)
            }
        }
    }
    
    private func connectRoomOrPlayer(accessToken: String) {
        roomManager.connect(roomName: config.streamName, accessToken: accessToken)
    }
    
    private func handleError(_ error: Error) {
        disconnect()
        errorPublisher.send(error)
    }
}
