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

class RoomViewModel: ObservableObject {
    enum State {
        case disconnected
        case connecting
        case connected
    }
    
    enum Layout {
        case gallery
        case speaker
    }

    @Published var state = State.disconnected
    @Published var layout: Layout = .gallery
    @Published var isShowingRoom = true
    @Published var isShowingStats = false
    @Published var isShowingError = false
    private(set) var error: Error?
    private var isAutoLayoutSwitchingEnabled = true
    private var callManager: CallManager!
    private var speakerLayoutViewModel: SpeakerLayoutViewModel!
    private var subscriptions = Set<AnyCancellable>()

    func configure(callManager: CallManager, speakerLayoutViewModel: SpeakerLayoutViewModel) {
        self.callManager = callManager
        self.speakerLayoutViewModel = speakerLayoutViewModel

        callManager.connectPublisher
            .sink { [weak self] in self?.state = .connected }
            .store(in: &subscriptions)

        callManager.disconnectPublisher
            .sink { [ weak self] error in
                self?.state = .disconnected

                if let error = error {
                    self?.error = error
                    self?.isShowingError = true
                } else {
                    self?.isShowingRoom = false
                }
            }
            .store(in: &subscriptions)

        speakerLayoutViewModel.$isPresenting
            .sink { [weak self] isPresenting in self?.handleIsPresentingChange(isPresenting: isPresenting) }
            .store(in: &subscriptions)
    }
    
    func connect(roomName: String) {
        guard callManager != nil else {
            return /// When not configured do nothing so `PreviewProvider` doesn't crash.
        }

        state = .connecting
        callManager.connect(roomName: roomName)
    }
    
    func disconnect() {
        callManager.disconnect()
    }

    /// A user can manually switch layout to override auto layout.
    func switchToLayout(_ layout: Layout) {
        self.layout = layout

        switch layout {
        case .gallery:
            break
        case .speaker:
            /// Turn auto layout back on when there is a presentation and the user switched back to speaker layout
            isAutoLayoutSwitchingEnabled = speakerLayoutViewModel.isPresenting
        }
    }
    
    private func handleIsPresentingChange(isPresenting: Bool) {
        if isPresenting {
            switch layout {
            case .gallery:
                /// The gallery layout does not show the presentation at all so we have to auto switch
                /// to speaker layout to inform the user that a presentation has started
                isAutoLayoutSwitchingEnabled = true
            case .speaker:
                break
            }

            layout = .speaker
        } else {
            if isAutoLayoutSwitchingEnabled {
                layout = .gallery
            }
        }
    }
}
