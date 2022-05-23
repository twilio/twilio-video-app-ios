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

import SwiftUI

struct TranscriptView: View {
    @EnvironmentObject var transcriptManager: TranscriptManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                ForEach($transcriptManager.transcript, id: \.self) { $message in
                    Text(message.userIdentity + ": " + message.message)
                        .font(.caption)
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
                .environmentObject(TranscriptManager.stub(transcript: [
                    .stub(userIdentity: "Bob", message: "Foo"),
                    .stub(userIdentity: "Alice", message: String(repeating: "caption ", count: 30)),
                    .stub(userIdentity: "Bob", message: "Bar")
                ]))
            TranscriptView()
                .environmentObject(TranscriptManager.stub(transcript: [
                    .stub(userIdentity: "Bob", message: "Just one line")
                ]))
        }
        .previewLayout(.sizeThatFits)
    }
}

extension TranscriptManager {
    static func stub(transcript: [TranscriptViewModel] = [
        .stub(userIdentity: "Bob", message: "This is a short caption."),
        .stub(userIdentity: "Alice", message: String(repeating: "caption ", count: 30))
    ]) -> TranscriptManager {
        let manager = TranscriptManager()
        manager.transcript = transcript
        return manager
    }
}

extension TranscriptViewModel {
    static func stub(
        id: String = UUID().uuidString,
        userIdentity: String = "Bob",
        message: String = "Hello"
    ) -> TranscriptViewModel {
        TranscriptViewModel(id: id, userIdentity: userIdentity, message: message)
    }
    
    private init(id: String = UUID().uuidString, userIdentity: String, message: String) {
        self.userIdentity = userIdentity
        self.message = message
        self.id = id
    }
}
