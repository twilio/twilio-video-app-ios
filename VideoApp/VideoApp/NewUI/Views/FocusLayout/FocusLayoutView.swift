//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI

/// Displays the dominant speaker and presentation track.
struct FocusLayoutView: View {
    @EnvironmentObject var viewModel: FocusLayoutViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    let spacing: CGFloat

    private var isPortraitOrientation: Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .compact
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: spacing) {
                VStack(spacing: spacing) {
                    PresentationStatusView(presenterIdentity: viewModel.presenter.identity)
                    ParticipantView(viewModel: $viewModel.dominantSpeaker)

                    if isPortraitOrientation {
                        PresentationView(videoTrack: $viewModel.presenter.presentationTrack)
                    }
                }
                // For landscape orientation only use 30% of the width for stuff that isn't the presentation video
                .frame(width: isPortraitOrientation ? nil : geometry.size.width * 0.3)
                
                if !isPortraitOrientation {
                    PresentationView(videoTrack: $viewModel.presenter.presentationTrack)
                }
            }
            .padding(.bottom, spacing)
        }
    }
}

struct FocusLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FocusLayoutView(spacing: 6)
                .previewDisplayName("Portrait")
                .frame(width: 300, height: 600)
            FocusLayoutView(spacing: 6)
                .previewDisplayName("Landscape")
                .frame(width: 600, height: 300)
        }
        .environmentObject(FocusLayoutViewModel.stub(isPresenting: true))
        .previewLayout(.sizeThatFits)
    }
}

extension FocusLayoutViewModel {
    static func stub(
        isPresenting: Bool = false,
        dominantSpeakerIdentity: String = "Bob",
        presenterIdentity: String = "Alice"
    ) -> FocusLayoutViewModel {
        let viewModel = FocusLayoutViewModel()
        viewModel.isPresenting = isPresenting
        viewModel.dominantSpeaker = ParticipantViewModel.stub(identity: dominantSpeakerIdentity)
        viewModel.presenter = Presenter(identity: presenterIdentity)
        return viewModel
    }
}
