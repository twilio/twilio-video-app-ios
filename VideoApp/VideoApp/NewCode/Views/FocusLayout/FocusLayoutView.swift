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
            .padding([.bottom, .horizontal], spacing)
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
