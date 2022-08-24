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

/// Main home screen for the app.
struct HomeView: View {
    @StateObject private var callManager = CallManager()
    @StateObject private var roomManager = RoomManager()
    @StateObject private var localParticipant = LocalParticipantManager()
    @StateObject private var mediaSetupViewModel = MediaSetupViewModel()
    @State private var roomName = ""
    @State private var isShowingMediaSetup = false
    @State private var isShowingRoom = false
    @State private var isShowingSettings = false
    @State private var isMediaSetup = false

    var body: some View {
        NavigationView {
            FormStack {
                Text("Twilio Programmable Video")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .padding(.top, -40) /// A little clunky but `FormStack` needs some work
                
                Text("Enter the name of a room you'd like to join.")
                
                TextField("Room name", text: $roomName)
                    .textFieldStyle(FormTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                Button("Continue") {
                    hideKeyboard()
                    isShowingMediaSetup = true
                }
                .buttonStyle(PrimaryButtonStyle(isEnabled: !roomName.isEmpty))
                .disabled(roomName.isEmpty)
            }
            .toolbar {
                Button(action: { isShowingSettings.toggle() }) {
                    Image(systemName: "gear")
                }
            }
            .sheet(isPresented: $isShowingMediaSetup) {
                MediaSetupView(roomName: roomName, isMediaSetup: $isMediaSetup)
                    .environmentObject(mediaSetupViewModel)
                    .onDisappear {
                        isShowingRoom = isMediaSetup
                    }
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView()
            }
            .fullScreenCover(isPresented: $isShowingRoom) {
                RoomViewDependencyWrapper(roomName: roomName)
            }
        }
        // Note: StackNavigationViewStyle is deprecated from iOS 16.0 onwards. Use NavigationStack view instead.
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            callManager.configure(roomManager: roomManager)
            roomManager.configure(localParticipant: localParticipant)
            localParticipant.configure(identity: AuthStore.shared.userDisplayName)
            mediaSetupViewModel.configure(localParticipant: localParticipant)

            if let deepLink = DeepLinkStore.shared.consumeDeepLink() {
                switch deepLink {
                case let .room(roomName):
                    self.roomName = roomName
                }
            }
        }
        .environmentObject(callManager)
        .environmentObject(roomManager)
        .environmentObject(localParticipant)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
