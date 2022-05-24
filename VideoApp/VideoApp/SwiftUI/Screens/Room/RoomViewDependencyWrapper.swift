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

/// Setup dependencies for `RoomView`.
///
/// This seems kind of odd but it is the best solution I have come up with so far. By using a wrapper like this
/// dependencies are injected into `RoomView` as `@EnvironmentObject` which works well for UI previews. If
/// `RoomView` created the dependencies with `@StateObject` it would be more difficult to configure the
/// UI previews. If `HomeView` created the dependencies, they would not get deallocated when `RoomView`
/// goes away. Also `HomeView` shouldn't have to do complex dependency setup for other screens.
struct RoomViewDependencyWrapper: View {
    @EnvironmentObject var localParticipant: LocalParticipantManager
    let roomName: String
    @StateObject private var roomViewModel: RoomViewModel
    @StateObject private var gridLayoutViewModel = GridLayoutViewModel()
    @StateObject private var focusLayoutViewModel = FocusLayoutViewModel()
    @StateObject private var roomManager = RoomManager()
    @StateObject private var captionsManager = CaptionsManager()

    init(roomName: String) {
        /// This custom init is only to fix warning.
        /// https://stackoverflow.com/questions/71396296/how-do-i-fix-expression-requiring-global-actor-mainactor-cannot-appear-in-def
        self.roomName = roomName
        self._roomViewModel = StateObject(wrappedValue: RoomViewModel())
    }
    
    var body: some View {
        Group {
            RoomView(roomName: roomName)
        }
        .environmentObject(roomViewModel)
        .environmentObject(gridLayoutViewModel)
        .environmentObject(focusLayoutViewModel)
        .environmentObject(roomManager)
        .environmentObject(captionsManager)
        .onAppear {
            roomManager.configure(localParticipant: localParticipant, captionsManager: captionsManager)
            roomViewModel.configure(roomManager: roomManager, focusLayoutViewModel: focusLayoutViewModel)
            gridLayoutViewModel.configure(roomManager: roomManager)
            focusLayoutViewModel.configure(roomManager: roomManager)
        }
    }
}
