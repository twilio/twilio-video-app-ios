//
//  TranscriptView.swift
//  Video-Internal
//
//  Created by Tim Rozum on 5/20/22.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import SwiftUI

struct TranscriptView: View {
    @EnvironmentObject var transcriptManager: TranscriptManager
    
    var body: some View {
        VStack {
            Spacer()
            
            ForEach($transcriptManager.transcript, id: \.self) { $message in
                Text(message.userIdentity + ": " + message.message)
                    .padding(5)
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.7))
            }
        }
    }
}

struct TranscriptView_Previews: PreviewProvider {
    static var previews: some View {
        TranscriptView()
            .environmentObject(TranscriptManager.stub(transcript: [TranscriptViewModel(userIdentity: "Bob", message: "Foo", id: 0)]))
    }
}

extension TranscriptManager {
    static func stub(transcript: [TranscriptViewModel]) -> TranscriptManager {
        let manager = TranscriptManager()
        manager.transcript = transcript
        return manager
    }
}
