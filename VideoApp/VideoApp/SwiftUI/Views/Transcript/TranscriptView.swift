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
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                ForEach($transcriptManager.transcript, id: \.self) { $message in
                    Text(message.userIdentity + ": " + message.message)
                        .padding(5)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.7))
                }
            }
            Spacer()
        }
    }
}

struct TranscriptView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TranscriptView()
                .environmentObject(TranscriptManager.stub(transcript: [TranscriptViewModel(userIdentity: "Bob", message: "Foo")]))
            TranscriptView()
                .environmentObject(TranscriptManager.stub(transcript: [
                    TranscriptViewModel(userIdentity: "Bob", message: "Foo"),
                    TranscriptViewModel(userIdentity: "Bob", message: "Foo"),
                    TranscriptViewModel(userIdentity: "Bob", message: "Foo asdf asdf asd fssd asdf asdf asd fasd siasdf"),
                    TranscriptViewModel(userIdentity: "Bob", message: "Foo")
                ]))
        }
        .previewLayout(.sizeThatFits)
    }
}

extension TranscriptManager {
    static func stub(transcript: [TranscriptViewModel]) -> TranscriptManager {
        let manager = TranscriptManager()
        manager.transcript = transcript
        return manager
    }
}

extension TranscriptViewModel {
    init(userIdentity: String, message: String, id: String = UUID().uuidString) {
        self.userIdentity = userIdentity
        self.message = message
        self.id = id
    }
}
