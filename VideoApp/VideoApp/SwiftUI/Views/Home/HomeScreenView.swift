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

struct HomeScreenView: View {
    @State private var roomName = ""
    @State private var showSettings = false
    @State private var showRoom = false

    @StateObject private var streamViewModel = StreamViewModel()
    @StateObject private var streamManager = StreamManager()
    @StateObject private var speakerSettingsManager = SpeakerSettingsManager()
    @StateObject private var speakerGridViewModel = SpeakerGridViewModel()
    @StateObject private var presentationLayoutViewModel = PresentationLayoutViewModel()

    var body: some View {
        NavigationView {
            FormStack {
                TextField("Room name", text: $roomName)
                    .textFieldStyle(FormTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                VStack {
                    Button("Continue") {
                        showRoom = true
                    }
                    .buttonStyle(PrimaryButtonStyle(isEnabled: !roomName.isEmpty))
                    .disabled(roomName.isEmpty)
                }
            }
            .navigationBarTitle("Join room", displayMode: .inline)
            .toolbar {
                Button(action: { showSettings.toggle() }) {
                    Image(systemName: "gear")
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .fullScreenCover(isPresented: $showRoom) {
                Group {
                    StreamView(config: StreamConfig(streamName: roomName, userIdentity: AuthStore.shared.userDisplayName))
                }
                .environmentObject(streamViewModel)
                .environmentObject(streamManager)
                .environmentObject(speakerGridViewModel)
                .environmentObject(presentationLayoutViewModel)
                .environmentObject(speakerSettingsManager)
                .onAppear {
                    let localParticipant = LocalParticipantManager(identity: AuthStore.shared.userDisplayName)
                    let roomManager = RoomManager()
                    roomManager.configure(localParticipant: localParticipant)
                    streamManager.configure(roomManager: roomManager)
                    streamViewModel.configure(streamManager: streamManager, speakerSettingsManager: speakerSettingsManager)
                    speakerSettingsManager.configure(roomManager: roomManager)
                    speakerGridViewModel.configure(roomManager: roomManager)
                    presentationLayoutViewModel.configure(roomManager: roomManager)
                }
            }
        }
    }
}

struct HomeScreenView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreenView()
    }
}
