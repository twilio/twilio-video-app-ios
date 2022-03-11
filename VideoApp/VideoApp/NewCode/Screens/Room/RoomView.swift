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

/// Room screen that is shown when a user connects to a video room.
struct RoomView: View {
    @EnvironmentObject var viewModel: RoomViewModel
    @EnvironmentObject var gridLayoutViewModel: GridLayoutViewModel
    @EnvironmentObject var focusLayoutViewModel: FocusLayoutViewModel
    @EnvironmentObject var localParticipant: LocalParticipantManager
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    let roomName: String
    private let app = UIApplication.shared
    private let spacing: CGFloat = 6
    
    private var isPortraitOrientation: Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .compact
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.backgroundBrandStronger.ignoresSafeArea()

                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        RoomStatusView(roomName: roomName)
                            .padding(.horizontal, spacing)

                        if focusLayoutViewModel.isPresenting {
                            FocusLayoutView(spacing: spacing)
                        } else {
                            GridLayoutView(spacing: spacing)
                        }
                    }
                    .padding(.leading, geometry.safeAreaInsets.leading)
                    .padding(.trailing, geometry.safeAreaInsets.trailing)
                    .padding(.top, geometry.safeAreaInsets.top.isZero ? 3 : 0)
                    
                    RoomToolbar {
                        RoomToolbarButton(
                            image: Image(systemName: "phone.down.fill"),
                            role: .destructive
                        ) {
                            viewModel.disconnect()
                            presentationMode.wrappedValue.dismiss()
                        }
                        RoomToolbarButton(
                            image: Image(systemName: localParticipant.isMicOn ? "mic" : "mic.slash")
                        ) {
                            localParticipant.isMicOn.toggle()
                        }
                        RoomToolbarButton(
                            image: Image(systemName: localParticipant.isCameraOn ? "video" : "video.slash")
                        ) {
                            localParticipant.isCameraOn.toggle()
                        }
                    }
                    
                    // For toolbar bottom that is below safe area
                    Color.background
                        .frame(height: geometry.safeAreaInsets.bottom)
                }
                .edgesIgnoringSafeArea([.horizontal, .bottom]) // So toolbar sides and bottom extend beyond safe area

                if viewModel.state == .connecting {
                    ProgressHUD(title: "Connecting...")
                }
            }
        }
        .onAppear {
            app.isIdleTimerDisabled = true // Disable lock screen
            viewModel.connect(roomName: roomName)
        }
        .onDisappear {
            app.isIdleTimerDisabled = false
        }
        .alert(isPresented: $viewModel.isShowingError) {
            Alert(error: viewModel.error!) {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct RoomView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Group {
                RoomView(roomName: "Demo")
                    .previewDisplayName("Grid layout")
                    .environmentObject(FocusLayoutViewModel.stub())

                RoomView(roomName: "Demo")
                    .previewDisplayName("Focus layout")
                    .environmentObject(FocusLayoutViewModel.stub(isPresenting: true))
            }
            .environmentObject(RoomViewModel.stub())
            .environmentObject(GridLayoutViewModel.stub())
            .environmentObject(RoomManager.stub())

            RoomView(roomName: "Demo")
                .previewDisplayName("Connecting")
                .environmentObject(RoomViewModel.stub(state: .connecting))
                .environmentObject(GridLayoutViewModel.stub(participantCount: 0))
                .environmentObject(FocusLayoutViewModel.stub())
                .environmentObject(RoomManager.stub(isRecording: false))
        }
        .environmentObject(LocalParticipantManager())
    }
}

extension RoomViewModel {
    static func stub(state: State = .connected) -> RoomViewModel {
        let viewModel = RoomViewModel()
        viewModel.state = state
        return viewModel
    }
}
