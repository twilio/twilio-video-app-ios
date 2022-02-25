//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct SpeakerGridView: View {
    @EnvironmentObject var viewModel: SpeakerGridViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    let spacing: CGFloat

    private var isPortraitOrientation: Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .compact
    }

    private var rowCount: Int {
        if isPortraitOrientation {
            return (viewModel.onscreenSpeakers.count + viewModel.onscreenSpeakers.count % columnCount) / columnCount
        } else {
            return viewModel.onscreenSpeakers.count < 5 ? 1 : 2
        }
    }
    
    private var columnCount: Int {
        if isPortraitOrientation {
            return viewModel.onscreenSpeakers.count < 4 ? 1 : 2
        } else {
            return (viewModel.onscreenSpeakers.count + viewModel.onscreenSpeakers.count % rowCount) / rowCount
        }
    }
    
    private var columns: [GridItem] {
        [GridItem](
            repeating: GridItem(.flexible(), spacing: spacing),
            count: columnCount
        )
    }
    
    var body: some View {
        VStack {
            if viewModel.onscreenSpeakers.isEmpty {
                Spacer()
            } else {
                GeometryReader { geometry in
                    LazyVGrid(columns: columns, spacing: spacing) {
                        ForEach($viewModel.onscreenSpeakers, id: \.self) { $speaker in
                            SpeakerVideoView(speaker: $speaker)
                                .frame(height: geometry.size.height / CGFloat(rowCount) - spacing)
                        }
                    }
                }
            }
        }
    }
}

struct SpeakerGridView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach((1...6), id: \.self) {
                SpeakerGridView(spacing: 6)
                    .environmentObject(SpeakerGridViewModel.stub(onscreenSpeakerCount: $0))
            }
            .frame(width: 400, height: 700)

            ForEach((1...6), id: \.self) {
                SpeakerGridView(spacing: 6)
                    .environmentObject(SpeakerGridViewModel.stub(onscreenSpeakerCount: $0))
            }
            .frame(width: 700, height: 300)
        }
        .previewLayout(.sizeThatFits)
    }
}

extension SpeakerGridViewModel {
    static func stub(onscreenSpeakerCount: Int = 6, offscreenSpeakerCount: Int = 0) -> SpeakerGridViewModel {
        let viewModel = SpeakerGridViewModel()

        viewModel.onscreenSpeakers = Array(1...onscreenSpeakerCount)
            .map { SpeakerVideoViewModel(identity: "Speaker \($0)") }
        
        if offscreenSpeakerCount > 1 {
            viewModel.offscreenSpeakers = Array(1...offscreenSpeakerCount)
                .map { SpeakerVideoViewModel(identity: "Offscreen \($0)") }
        }
        
        return viewModel
    }
}
