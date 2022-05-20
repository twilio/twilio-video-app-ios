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
import TwilioVideo

class TranscriptManager: NSObject, ObservableObject {
    @Published var transcript: [TranscriptViewModel] = []
    private var subscriptions = Set<AnyCancellable>()

    var participant: RemoteParticipant? {
        didSet {
            oldValue?.delegate = nil // TODO: remove data track also
            subscriptions.removeAll()
            
            if let participant = participant {
                participant.delegate = self
                
                Timer.publish(every: 1, on: .main, in: .default)
                    .autoconnect()
                    .sink { [weak self] date in
                        self?.transcript.removeAll(where: { date.timeIntervalSince($0.date) > 10 })
                    }
                    .store(in: &subscriptions)
            }
        }
    }
}

extension TranscriptManager: RemoteParticipantDelegate {
    func didSubscribeToDataTrack(
        dataTrack: RemoteDataTrack,
        publication: RemoteDataTrackPublication,
        participant: RemoteParticipant
    ) {
        dataTrack.delegate = self
    }
}

// TODO: Send data instead of string
extension TranscriptManager: RemoteDataTrackDelegate {
    func remoteDataTrackDidReceiveString(remoteDataTrack: RemoteDataTrack, message: String) {
        guard
            let data = message.data(using: .utf8),
            let message = try? JSONDecoder().decode(TranscriptMessage.self, from: data),
            let viewModel = TranscriptViewModel(transcriptMessage: message)
        else {
            return
        }

        if let index = transcript.firstIndex(where: { $0.id == viewModel.id }) {
            transcript[index] = viewModel
        } else {
            transcript.append(viewModel)
            
            if transcript.count > 4 {
                transcript.removeFirst()
            }
        }
    }
}
