//
//  TranscriptViewModel.swift
//  Video-Internal
//
//  Created by Tim Rozum on 5/20/22.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import Foundation

struct TranscriptViewModel: Hashable {
    let userIdentity: String
    let message: String
    let id: Int // TODO: Use string
    let date = Date()
    
    init?(transcriptMessage: TranscriptMessage) {
        guard
            let firstResult = transcriptMessage.transcriptionResponse.TranscriptEvent.Transcript.Results.first,
            let text = firstResult.Alternatives.first?.Transcript
        else {
            return nil
        }

        userIdentity = transcriptMessage.participantIdentity
        message = text
        id = firstResult.ResultId
    }
    
    init(userIdentity: String, message: String, id: Int) {
        self.userIdentity = userIdentity
        self.message = message
        self.id = id
    }
}
