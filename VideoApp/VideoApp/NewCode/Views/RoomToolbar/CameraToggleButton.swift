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

struct CameraToggleButton: View {
    @EnvironmentObject var localParticipant: LocalParticipantManager

    var body: some View {
        RoomToolbarButton(
            image: Image(systemName: localParticipant.isCameraOn ? "video" : "video.slash")
        ) {
            localParticipant.isCameraOn.toggle()
        }
    }
}

struct CameraToggleButton_Previews: PreviewProvider {
    static var previews: some View {
        ForEach([true, false], id: \.self) { isCameraOn in
            CameraToggleButton()
                .environmentObject(LocalParticipantManager.stub(isCameraOn: isCameraOn))
        }
        .previewLayout(.sizeThatFits)
    }
}
