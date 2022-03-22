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
            
            if localParticipant.isCameraOn {
                Button {
                    localParticipant.cameraPosition = localParticipant.cameraPosition == .front ? .back : .front
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath.camera")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(13)
                        .foregroundColor(.white)
                }
            }
        }
        .frame(height: 44) // So buttons are easy to tap
    }
}

struct RoomStatusView_Previews: PreviewProvider {
    static var previews: some View {
        let roomNames = ["Short room name", "Long room name that is truncated because it does not fit"]
        
        ForEach([false, true], id: \.self) { isRecording in
            ForEach([false, true], id: \.self) { isCameraOn in
                ForEach(roomNames, id: \.self) { roomName in
                    RoomStatusView(roomName: roomName)
                        .environmentObject(RoomManager.stub(isRecording: isRecording))
                        .environmentObject(LocalParticipantManager.stub(isCameraOn: isCameraOn))
                        .frame(width: 400)
                        .background(Color.roomBackground)
                        .previewLayout(.sizeThatFits)
                }
            }
        }
    }
}

extension RoomManager {
    static func stub(isRecording: Bool = false) -> RoomManager {
        let roomManager = RoomManager()
        roomManager.isRecording = isRecording
        return roomManager
    }
}

extension LocalParticipantManager {
    static func stub(isCameraOn: Bool = true, isMicOn: Bool = true) -> LocalParticipantManager {
        let localParticipant = LocalParticipantManager()
        localParticipant.isCameraOn = isCameraOn
        localParticipant.isMicOn = isMicOn
        return localParticipant
    }
}
