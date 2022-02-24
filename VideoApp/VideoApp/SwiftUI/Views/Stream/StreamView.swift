//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct StreamView: View {
    @StateObject private var viewModel = StreamViewModel()
    @StateObject private var streamManager = StreamManager()
    @StateObject private var speakerSettingsManager = SpeakerSettingsManager()
    @StateObject private var speakerGridViewModel = SpeakerGridViewModel()
    @StateObject private var presentationLayoutViewModel = PresentationLayoutViewModel()

    
    
//    @EnvironmentObject var viewModel: StreamViewModel
//    @EnvironmentObject var streamManager: StreamManager
//    @EnvironmentObject var speakerSettingsManager: SpeakerSettingsManager
//    @EnvironmentObject var speakerGridViewModel: SpeakerGridViewModel
//    @EnvironmentObject var presentationLayoutViewModel: PresentationLayoutViewModel
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
                        StreamStatusView(streamName: config.streamName, streamState: $streamManager.state)
                            .padding(.bottom, spacing)

                        HStack(spacing: 0) {
                            if presentationLayoutViewModel.isPresenting {
                                PresentationLayoutView(spacing: spacing)
                            } else {
                                SpeakerGridView(spacing: spacing)
                            }

                            if !isPortraitOrientation && !speakerGridViewModel.offscreenSpeakers.isEmpty {
                                OffscreenSpeakersView()
                                    .frame(width: 100)
                                    .padding([.leading, .bottom], spacing)
                            }
                        }
                        
                        if isPortraitOrientation && !speakerGridViewModel.offscreenSpeakers.isEmpty {
                            OffscreenSpeakersView()
                                .padding(.bottom, spacing)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.leading, geometry.safeAreaInsets.leading.isZero ? spacing : geometry.safeAreaInsets.leading)
                    .padding(.trailing, geometry.safeAreaInsets.trailing.isZero ? spacing : geometry.safeAreaInsets.trailing)
                    .padding(.top, geometry.safeAreaInsets.top.isZero ? 3 : 0)
                    
                    StreamToolbar {
                        StreamToolbarButton(
                            image: Image(systemName: "arrow.left"),
                            role: .destructive
                        ) {
                            leaveStream()
                        }
                        StreamToolbarButton(
                            image: Image(systemName: speakerSettingsManager.isMicOn ? "mic" : "mic.slash")
                        ) {
                            speakerSettingsManager.isMicOn.toggle()
                        }
                        StreamToolbarButton(
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
        .environmentObject(viewModel)
        .environmentObject(streamManager)
        .environmentObject(speakerGridViewModel)
        .environmentObject(presentationLayoutViewModel)
        .environmentObject(speakerSettingsManager)
        .onAppear {
            let localParticipant = LocalParticipantManager(identity: AuthStore.shared.userDisplayName)
            let roomManager = RoomManager()
            roomManager.configure(localParticipant: localParticipant)
            streamManager.configure(roomManager: roomManager)
            streamManager.config = config
            viewModel.configure(streamManager: streamManager, speakerSettingsManager: speakerSettingsManager)
            speakerSettingsManager.configure(roomManager: roomManager)
            speakerGridViewModel.configure(roomManager: roomManager)
            presentationLayoutViewModel.configure(roomManager: roomManager)
            
            
            
            app.isIdleTimerDisabled = true
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

//struct StreamView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            Group {
//                StreamView()
//                    .previewDisplayName("Host")
//                    .environmentObject(StreamManager(config: .stub(role: .host)))
//                StreamView()
//                    .previewDisplayName("Speaker")
//                    .environmentObject(StreamManager(config: .stub(role: .speaker)))
//            }
//            .environmentObject(SpeakerGridViewModel.stub())
//            .environmentObject(PresentationLayoutViewModel.stub())
//
//            StreamView()
//                .previewDisplayName("Offscreen Speakers")
//                .environmentObject(StreamManager(config: .stub(role: .speaker)))
//                .environmentObject(SpeakerGridViewModel.stub(offscreenSpeakerCount: 10))
//                .environmentObject(PresentationLayoutViewModel.stub())
//
//            StreamView()
//                .previewDisplayName("Presentation")
//                .environmentObject(StreamManager(config: .stub(role: .speaker)))
//                .environmentObject(SpeakerGridViewModel.stub())
//                .environmentObject(PresentationLayoutViewModel.stub(isPresenting: true))
//
//            Group {
//                StreamView()
//                    .previewDisplayName("Viewer")
//                    .environmentObject(StreamManager(config: .stub(role: .viewer)))
//                StreamView()
//                    .previewDisplayName("Joining")
//                    .environmentObject(StreamManager(config: .stub(role: .viewer), state: .connecting))
//            }
//            .environmentObject(SpeakerGridViewModel())
//            .environmentObject(PresentationLayoutViewModel.stub())
//        }
//        .environmentObject(SpeakerSettingsManager())
//        .environmentObject(StreamViewModel())
//    }
//}

//extension StreamManager {
//    convenience init(config: StreamConfig = .stub(), state: StreamManager.State = .connected) {
//        self.init()
//        self.config = config
//        self.state = state
//    }
//}
//
//extension StreamConfig {
//    static func stub(streamName: String = "Demo", userIdentity: String = "Alice", role: Role = .host) -> Self {
//        StreamConfig(streamName: streamName, userIdentity: userIdentity, role: role)
//    }
//}
