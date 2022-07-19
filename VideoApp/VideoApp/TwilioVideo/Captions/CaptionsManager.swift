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

/// Receive captions on a data track from the `media-transcriber` participant. Discard old captions
/// when time has elapsed or space for new captions is needed. The `media-transcriber` participant
/// is only for receiving captions and should not be visible in the UI.
class CaptionsManager: NSObject, ObservableObject {
    @Published var captions: [Caption] = []
    let errorPublisher = PassthroughSubject<Error, Never>()

    var isCaptionsEnabled = false {
        didSet {
            guard oldValue != isCaptionsEnabled else { return }

            reset()
        }
    }

    var transcriber: RemoteParticipant? {
        didSet {
            guard oldValue != transcriber else { return }

            oldValue?.removeDelegates()
            reset()
        }
    }

    private var subscriptions = Set<AnyCancellable>()

    private func reset() {
        transcriber?.removeDelegates()
        captions.removeAll()
        subscriptions.removeAll()

        guard isCaptionsEnabled else {
            return
        }
        
        guard let transcriber = transcriber else {
            handleError(VideoAppError.mediaTranscriberNotConnected)
            return
        }
        
        guard !transcriber.hasTranscriberError else {
            handleError(VideoAppError.transcriberError)
            return
        }
        
        transcriber.delegate = self
        transcriber.remoteDataTracks.forEach { $0.remoteTrack?.delegate = self }
        
        Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] date in
                self?.captions.removeAll(where: { date.timeIntervalSince($0.date) > 10 })
            }
            .store(in: &subscriptions)
    }
    
    private func handleError(_ error: Error) {
        isCaptionsEnabled = false
        errorPublisher.send(error)
    }
}

extension CaptionsManager: RemoteParticipantDelegate {
    func didSubscribeToDataTrack(
        dataTrack: RemoteDataTrack,
        publication: RemoteDataTrackPublication,
        participant: RemoteParticipant
    ) {
        if dataTrack.isTranscriberError {
            handleError(VideoAppError.transcriberError)
        } else {
            dataTrack.delegate = self
        }
    }
}

extension CaptionsManager: RemoteDataTrackDelegate {
    func remoteDataTrackDidReceiveString(remoteDataTrack: RemoteDataTrack, message: String) {
        guard let data = message.data(using: .utf8) else {
            handleError(VideoAppError.stringIsNotUTF8)
            return
        }

        let transcription: Transcription
        
        do {
            transcription = try JSONDecoder().decode(Transcription.self, from: data)
        } catch {
            handleError(error)
            return
        }

        transcription.transcriptionResponse.TranscriptEvent.Transcript.Results
            .compactMap { Caption(result: $0) }
            .forEach { caption in
                if let index = captions.firstIndex(where: { $0.id == caption.id }) {
                    captions[index] = caption
                } else {
                    captions.append(caption)
                    
                    if captions.count > 3 {
                        captions.removeFirst()
                    }
                }
            }
    }
}

private extension RemoteParticipant {
    var hasTranscriberError: Bool {
        remoteDataTracks.compactMap { $0.remoteTrack }.first { $0.isTranscriberError } != nil
    }
    
    func removeDelegates() {
        delegate = nil
        remoteDataTracks.forEach { $0.remoteTrack?.delegate = nil }
    }
}

private extension RemoteDataTrack {
    var isTranscriberError: Bool {
        /// Use the presence of this data track to signal the transcriber is not working correctly
        name == "transcriber-error"
    }
}
