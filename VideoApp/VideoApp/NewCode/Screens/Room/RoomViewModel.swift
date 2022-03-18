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

@MainActor class RoomViewModel: ObservableObject {
    enum State {
        case disconnected
        case connecting
        case connected
    }

    @Published var state = State.disconnected
    @Published var isShowingError = false
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
        isShowingError = true
    }

    func connect(roomName: String) {
        guard roomManager != nil else {
            return /// When not configured do nothing so `PreviewProvider` doesn't crash.
        }

        state = .connecting

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
