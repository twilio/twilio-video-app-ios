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
    
    enum Layout {
        case grid
        case focus
    }

    @Published var state = State.disconnected
    @Published var layout: Layout = .grid
    @Published var isShowingStats = false
    @Published var isShowingError = false
    private(set) var error: Error?
    private let accessTokenStore = TwilioAccessTokenStore()
    private var isAutoLayoutSwitchingEnabled = true
    private var roomManager: RoomManager!
    private var focusLayoutViewModel: FocusLayoutViewModel!
    private var subscriptions = Set<AnyCancellable>()

    func configure(roomManager: RoomManager, focusLayoutViewModel: FocusLayoutViewModel) {
        self.roomManager = roomManager
        self.focusLayoutViewModel = focusLayoutViewModel

        roomManager.roomConnectPublisher
            .sink { [weak self] in self?.state = .connected }
            .store(in: &subscriptions)

        roomManager.roomDisconnectPublisher
            .compactMap { $0 }
            .sink { [ weak self] error in self?.handleError(error) }
            .store(in: &subscriptions)
        
        roomManager.localParticipant.errorPublisher
            .sink { [weak self] error in self?.handleError(error) }
            .store(in: &subscriptions)
        
        focusLayoutViewModel.$isPresenting
            .sink { [weak self] isPresenting in self?.handleIsPresentingChange(isPresenting: isPresenting) }
            .store(in: &subscriptions)
    }
    
    func connect(roomName: String) {
        guard roomManager != nil else {
            return /// When not configured do nothing so `PreviewProvider` doesn't crash.
        }

        state = .connecting

        // How to handle failures?
        CallKitManager.shared.startCall(roomName: roomName)
        
//        Task {
//            do {
//                let accessToken = try await accessTokenStore.fetchTwilioAccessToken(roomName: roomName)
//                roomManager.connect(roomName: roomName, accessToken: accessToken)
//            } catch {
//                handleError(error)
//            }
//        }
    }
    
    func disconnect() {
        if let uuid = roomManager.room?.uuid {
            CallKitManager.shared.endCall(uuid: uuid)
        }
        
//        roomManager.disconnect()
        state = .disconnected
        roomManager.localParticipant.isMicOn = false
        roomManager.localParticipant.isCameraOn = false
    }

    /// A user can manually switch layout to override auto layout.
    func switchToLayout(_ layout: Layout) {
        self.layout = layout

        switch layout {
        case .grid:
            break
        case .focus:
            /// Turn auto layout back on when there is a presentation and the user switched back to focus layout
            isAutoLayoutSwitchingEnabled = focusLayoutViewModel.isPresenting
        }
    }
    
    private func handleIsPresentingChange(isPresenting: Bool) {
        if isPresenting {
            switch layout {
            case .grid:
                /// The grid does not show the presentation at all so we have to auto switch to
                /// focus to inform the user that a presentation has started
                isAutoLayoutSwitchingEnabled = true
            case .focus:
                break
            }

            layout = .focus
        } else {
            if isAutoLayoutSwitchingEnabled {
                layout = .grid
            }
        }
    }

    private func handleError(_ error: Error) {
        disconnect()
        self.error = error
        isShowingError = true
    }
}
