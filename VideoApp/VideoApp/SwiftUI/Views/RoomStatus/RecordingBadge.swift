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

struct RecordingBadge: View {
    @State private var isBright = false

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .frame(width: 12)
                .foregroundColor(isBright ? .recordingDotBright : .recordingDotDark)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                        isBright.toggle()
                    }
                }
            
            Text("Recording")
                .foregroundColor(.white)
                .font(.system(size: 14))
        }
        .frame(height: 14)
        .padding(6)
        .background(Color.white.opacity(0.25))
        .cornerRadius(3)
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct RecordingBadge_Previews: PreviewProvider {
    static var previews: some View {
        RecordingBadge()
            .padding()
            .background(Color.roomBackground)
            .previewLayout(.sizeThatFits)
    }
}
