//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct RoomScreenView: View {
    @EnvironmentObject var viewModel: RoomScreenViewModel
    @EnvironmentObject var streamManager: StreamManager
    @EnvironmentObject var speakerSettingsManager: SpeakerSettingsManager
    @EnvironmentObject var speakerGridViewModel: SpeakerGridViewModel
    @EnvironmentObject var presentationLayoutViewModel: PresentationLayoutViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    let config: StreamConfig
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
                        RoomStatusView(streamName: config.streamName, streamState: $streamManager.state)
                            .padding(.bottom, spacing)

                        HStack(spacing: 0) {
                            if presentationLayoutViewModel.isPresenting {
                                PresentationLayoutView(spacing: spacing)
                            } else {
                                SpeakerGridView(spacing: spacing)
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

                if streamManager.state == .connecting {
                    ProgressHUD(title: "Connecting...")
                }
            }
        }
        .onAppear {
            app.isIdleTimerDisabled = true
            streamManager.config = config
            streamManager.connect()
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
        streamManager.disconnect()
        presentationMode.wrappedValue.dismiss()
    }
}

struct RoomScreenView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RoomScreenView(config: .stub())
                .previewDisplayName("Grid layout")
                .environmentObject(StreamManager())
                .environmentObject(SpeakerGridViewModel.stub())
                .environmentObject(PresentationLayoutViewModel.stub())

            RoomScreenView(config: .stub())
                .previewDisplayName("Presentation layout")
                .environmentObject(StreamManager())
                .environmentObject(SpeakerGridViewModel.stub())
                .environmentObject(PresentationLayoutViewModel.stub(isPresenting: true))

            RoomScreenView(config: .stub())
                .previewDisplayName("Connecting")
                .environmentObject(StreamManager(state: .connecting))
                .environmentObject(SpeakerGridViewModel())
                .environmentObject(PresentationLayoutViewModel.stub())
        }
        .environmentObject(SpeakerSettingsManager())
        .environmentObject(RoomScreenViewModel())
    }
}

extension StreamManager {
    convenience init(config: StreamConfig = .stub(), state: StreamManager.State = .connected) {
        self.init()
        self.config = config
        self.state = state
    }
}

extension StreamConfig {
    static func stub(streamName: String = "Demo", userIdentity: String = "Alice") -> Self {
        StreamConfig(streamName: streamName, userIdentity: userIdentity)
    }
}
