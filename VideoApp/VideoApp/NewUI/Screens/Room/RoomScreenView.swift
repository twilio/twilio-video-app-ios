//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct RoomScreenView: View {
    @EnvironmentObject var viewModel: RoomScreenViewModel
    @EnvironmentObject var localParticipant: LocalParticipantManager
    @EnvironmentObject var gridLayoutViewModel: GridLayoutViewModel
    @EnvironmentObject var focusLayoutViewModel: FocusLayoutViewModel
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
                        RoomStatusView(streamName: roomName)
                            .padding(.bottom, spacing)

                        HStack(spacing: 0) {
                            if focusLayoutViewModel.isPresenting {
                                FocusLayoutView(spacing: spacing)
                            } else {
                                GridLayoutView(spacing: spacing)
                            }
                        }
                    }
                    .padding(.leading, geometry.safeAreaInsets.leading.isZero ? spacing : geometry.safeAreaInsets.leading)
                    .padding(.trailing, geometry.safeAreaInsets.trailing.isZero ? spacing : geometry.safeAreaInsets.trailing)
                    .padding(.top, geometry.safeAreaInsets.top.isZero ? 3 : 0)
                    
                    RoomToolbar {
                        RoomToolbarButton(
                            image: Image(systemName: "arrow.left"),
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
            app.isIdleTimerDisabled = true
            viewModel.connect(roomName: roomName)
        }
        .onDisappear {
            app.isIdleTimerDisabled = false
        }
        .alert(item: $viewModel.alertIdentifier) { alertIdentifier in
            switch alertIdentifier {
            case .error:
                return Alert(error: viewModel.error!) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct RoomScreenView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RoomScreenView(roomName: "Demo")
                .previewDisplayName("Grid layout")
                .environmentObject(RoomScreenViewModel.stub())
                .environmentObject(GridLayoutViewModel.stub())
                .environmentObject(FocusLayoutViewModel.stub())

            RoomScreenView(roomName: "Demo")
                .previewDisplayName("Focus layout")
                .environmentObject(RoomScreenViewModel.stub())
                .environmentObject(GridLayoutViewModel.stub())
                .environmentObject(FocusLayoutViewModel.stub(isPresenting: true))

            RoomScreenView(roomName: "Demo")
                .previewDisplayName("Connecting")
                .environmentObject(RoomScreenViewModel.stub(state: .connecting))
                .environmentObject(GridLayoutViewModel.stub(onscreenSpeakerCount: 0))
                .environmentObject(FocusLayoutViewModel.stub())
        }
        .environmentObject(LocalParticipantManager())
    }
}

extension RoomScreenViewModel {
    static func stub(state: State = .connected) -> RoomScreenViewModel {
        let viewModel = RoomScreenViewModel()
        viewModel.state = state
        return viewModel
    }
}
