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

// 1. Want to inject for previews
// 2. Get code out of home screen
// 3. Deallocate dependencies when room screen is dismissed
struct RoomScreenViewDependencyContainer: View {
    let roomName: String
    @StateObject private var localParticipant = LocalParticipantManager()
    @StateObject private var roomScreenViewModel = RoomScreenViewModel()
    @StateObject private var gridLayoutViewModel = GridLayoutViewModel()
    @StateObject private var focusLayoutViewModel = FocusLayoutViewModel()

    var body: some View {
        Group {
            RoomScreenView(roomName: roomName)
        }
        .environmentObject(roomScreenViewModel)
        .environmentObject(gridLayoutViewModel)
        .environmentObject(focusLayoutViewModel)
        .environmentObject(localParticipant)
        .onAppear {
            localParticipant.configure(identity: AuthStore.shared.userDisplayName)
            let roomManager = RoomManager()
            roomManager.configure(localParticipant: localParticipant)
            roomScreenViewModel.configure(roomManager: roomManager)
            gridLayoutViewModel.configure(roomManager: roomManager)
            focusLayoutViewModel.configure(roomManager: roomManager)
        }
    }
}
