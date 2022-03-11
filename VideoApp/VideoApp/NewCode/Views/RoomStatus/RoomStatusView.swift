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

struct RoomStatusView: View {
    @EnvironmentObject var localParticipant: LocalParticipantManager
    @EnvironmentObject var roomManager: RoomManager
    let roomName: String

    var body: some View {
        HStack(spacing: 15) {
            Text(roomName)
                .foregroundColor(.white)
                .font(.system(size: 16))
                .lineLimit(1)

            if roomManager.isRecording {
                RecordingBadge()
            }
            
            Spacer()
            Button {
                localParticipant.cameraPosition = localParticipant.cameraPosition == .front ? .back : .front
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath.camera")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(10)
                    .frame(width: 44, height: 44)
                    .foregroundColor(.white)
            }
        }
        .background(Color.backgroundBrandStronger)
    }
}

struct RoomStatusView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Group {
                RoomStatusView(roomName: "Short room name")
                    .previewDisplayName("Short room name")
                RoomStatusView(roomName: "A very long room name that does not fit and is truncated")
                    .previewDisplayName("Long room name")
            }
            .environmentObject(RoomManager.stub(isRecording: false))

            Group {
                RoomStatusView(roomName: "Short room name")
                    .previewDisplayName("Recording and short room name")
                RoomStatusView(roomName: "A very long room name that does not fit and is truncated")
                    .previewDisplayName("Recording and long room name")
            }
            .environmentObject(RoomManager.stub())
        }
        .frame(width: 400)
        .previewLayout(.sizeThatFits)
    }
}

extension RoomManager {
    static func stub(isRecording: Bool = true) -> RoomManager {
        let roomManager = RoomManager()
        roomManager.isRecording = isRecording
        return roomManager
    }
}
