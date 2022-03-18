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
                    if viewModel.isPresenting {
                        PresentationStatusView(presenterIdentity: viewModel.presenter.identity)
                    }
                    
                    ParticipantView(viewModel: $viewModel.dominantSpeaker)

                    if isPortraitOrientation && viewModel.isPresenting {
                        PresentationView(videoTrack: $viewModel.presenter.presentationTrack)
                    }
                }
                // For landscape orientation only use 30% of the width for stuff that isn't the presentation video
                .frame(width: isPortraitOrientation || !viewModel.isPresenting ? nil : geometry.size.width * 0.3)
                
                if !isPortraitOrientation && viewModel.isPresenting {
                    PresentationView(videoTrack: $viewModel.presenter.presentationTrack)
                }
            }
            .padding([.bottom, .horizontal], spacing)
        }
    }
}

struct FocusLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach([false, true], id: \.self) { isPresenting in
            ForEach([[300.0, 600.0], [600.0, 300.0]], id: \.self) { size in
                FocusLayoutView(spacing: 6)
                    .previewDisplayName(isPresenting ? "Presenting" : "Not presenting")
                    .frame(width: size[0], height: size[1])
                    .environmentObject(FocusLayoutViewModel.stub(isPresenting: isPresenting))
                    .previewLayout(.sizeThatFits)
            }
        }
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
