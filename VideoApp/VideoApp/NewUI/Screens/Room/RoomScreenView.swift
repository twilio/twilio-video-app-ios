//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct RoomScreenView: View {
    @EnvironmentObject var viewModel: RoomScreenViewModel
    @EnvironmentObject var speakerSettingsManager: SpeakerSettingsManager
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
                            leaveStream()
                        }
                        RoomToolbarButton(
                            image: Image(systemName: speakerSettingsManager.isMicOn ? "mic" : "mic.slash")
                        ) {
                            speakerSettingsManager.isMicOn.toggle()
                        }
                        RoomToolbarButton(
                            image: Image(systemName: speakerSettingsManager.isCameraOn ? "video" : "video.slash")
                        ) {
                            speakerSettingsManager.isCameraOn.toggle()
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
            viewModel.roomName = roomName
            viewModel.connect()
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
    
    private func leaveStream() {
        viewModel.disconnect()
        presentationMode.wrappedValue.dismiss()
    }
}

struct RoomScreenView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RoomScreenView(roomName: "Demo")
                .previewDisplayName("Grid layout")
                .environmentObject(RoomScreenViewModel())
                .environmentObject(GridLayoutViewModel.stub())
                .environmentObject(FocusLayoutViewModel.stub())

            RoomScreenView(roomName: "Demo")
                .previewDisplayName("Presentation layout")
                .environmentObject(RoomScreenViewModel())
                .environmentObject(GridLayoutViewModel.stub())
                .environmentObject(FocusLayoutViewModel.stub(isPresenting: true))

            RoomScreenView(roomName: "Demo")
                .previewDisplayName("Connecting")
                .environmentObject(RoomScreenViewModel(state: .connecting))
                .environmentObject(GridLayoutViewModel())
                .environmentObject(FocusLayoutViewModel.stub())
        }
        .environmentObject(SpeakerSettingsManager())
    }
}

extension RoomScreenViewModel {
    convenience init(state: RoomScreenViewModel.State = .connected) {
        self.init()
        self.state = state
    }
}
