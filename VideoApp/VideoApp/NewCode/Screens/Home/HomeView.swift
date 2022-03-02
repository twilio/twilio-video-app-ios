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
    @State private var roomName = ""
    @State private var isShowingRoom = false
    @State private var isShowingSettings = false

    var body: some View {
        NavigationView {
            FormStack {
                TextField("Room name", text: $roomName)
                    .textFieldStyle(FormTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                VStack {
                    Button("Continue") {
                        isShowingRoom = true
                    }
                    .buttonStyle(PrimaryButtonStyle(isEnabled: !roomName.isEmpty))
                    .disabled(roomName.isEmpty)
                }
            }
            .navigationBarTitle("Join room", displayMode: .inline)
            .toolbar {
                Button(action: { isShowingSettings.toggle() }) {
                    Image(systemName: "gear")
                }
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView()
            }
            .fullScreenCover(isPresented: $isShowingRoom) {
                RoomViewDependencyWrapper(roomName: roomName)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
