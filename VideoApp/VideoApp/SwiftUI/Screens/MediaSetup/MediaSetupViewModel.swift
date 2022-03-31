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

class MediaSetupViewModel: ObservableObject {
    @Published var participant = ParticipantViewModel()
    private var localParticipant: LocalParticipantManager!
    private var subscriptions = Set<AnyCancellable>()

    func configure(localParticipant: LocalParticipantManager) {
        self.localParticipant = localParticipant

        localParticipant.changePublisher
            .map { ParticipantViewModel(participant: $0, shouldHideYou: true) }
            .sink { [weak self] participant in self?.participant = participant }
            .store(in: &subscriptions)
    }
}
