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
                Color.roomBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        RoomStatusView(roomName: roomName)
                            .padding(.horizontal, spacing)

                        switch viewModel.layout {
                        case .gallery:
                            GalleryLayoutView(spacing: spacing)
                        case .speaker:
                            SpeakerLayoutView(spacing: spacing)
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
                        }
                        MicToggleButton()
                        CameraToggleButton()
                        
                        Menu {
                            Button(
                                action: { viewModel.isShowingStats = true },
                                label: { Label("Stats", systemImage: "binoculars") }
                            )

                            switch viewModel.layout {
                            case .gallery:
                                Button(
                                    action: { viewModel.switchToLayout(.speaker) },
                                    label: { Label("Speaker View", systemImage: "person") }
                                )
                            case .speaker:
                                Button(
                                    action: { viewModel.switchToLayout(.gallery) },
                                    label: { Label("Gallery View", systemImage: "square.grid.2x2") }
                                )
                            }
                        } label: {
                            RoomToolbarButton(image: Image(systemName: "ellipsis"))
                        }
                    }
                    
                    // For toolbar bottom that is below safe area
                    Color.background
                        .frame(height: geometry.safeAreaInsets.bottom)
                }
                .edgesIgnoringSafeArea([.horizontal, .bottom]) // So toolbar sides and bottom extend beyond safe area

                StatsContainerView(isShowingStats: $viewModel.isShowingStats)
                
                if viewModel.state == .connecting {
                    ProgressHUD(title: "Joining Meeting")
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
        .onChange(of: viewModel.isShowingRoom) { isShowingRoom in
            if !isShowingRoom {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct RoomView_Previews: PreviewProvider {
    static var previews: some View {
        let roomName = "Demo"
        
        Group {
            Group {
                RoomView(roomName: roomName)
                    .previewDisplayName("Gallery layout")
                    .environmentObject(RoomViewModel.stub())
                    .environmentObject(SpeakerLayoutViewModel.stub())

                RoomView(roomName: roomName)
                    .previewDisplayName("Speaker layout")
                    .environmentObject(RoomViewModel.stub(layout: .speaker))
                    .environmentObject(SpeakerLayoutViewModel.stub(isPresenting: true))

                RoomView(roomName: roomName)
                    .previewDisplayName("Stats")
                    .environmentObject(RoomViewModel.stub(isShowingStats: true))
                    .environmentObject(SpeakerLayoutViewModel.stub())
            }
            .environmentObject(GalleryLayoutViewModel.stub())
            .environmentObject(RoomManager.stub(isRecording: true))

            RoomView(roomName: roomName)
                .previewDisplayName("Connecting")
                .environmentObject(RoomViewModel.stub(state: .connecting))
                .environmentObject(GalleryLayoutViewModel.stub(participantCount: 0))
                .environmentObject(SpeakerLayoutViewModel.stub())
                .environmentObject(RoomManager.stub())
        }
        .environmentObject(LocalParticipantManager.stub())
    }
}

extension RoomViewModel {
    static func stub(
        state: State = .connected,
        layout: Layout = .gallery,
        isShowingStats: Bool = false
    ) -> RoomViewModel {
        let viewModel = RoomViewModel()
        viewModel.state = state
        viewModel.layout = layout
        viewModel.isShowingStats = isShowingStats
        return viewModel
    }
}
