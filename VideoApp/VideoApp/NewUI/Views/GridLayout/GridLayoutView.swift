//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct GridLayoutView: View {
    @EnvironmentObject var viewModel: GridLayoutViewModel
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
                            ParticipantView(viewModel: $speaker)
                                .frame(height: geometry.size.height / CGFloat(rowCount) - spacing)
                        }
                    }
                }
            }
        }
    }
}

struct GridLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach((1...6), id: \.self) {
                GridLayoutView(spacing: 6)
                    .environmentObject(GridLayoutViewModel.stub(onscreenSpeakerCount: $0))
            }
            .frame(width: 400, height: 700)

            ForEach((1...6), id: \.self) {
                GridLayoutView(spacing: 6)
                    .environmentObject(GridLayoutViewModel.stub(onscreenSpeakerCount: $0))
            }
            .frame(width: 700, height: 300)
        }
        .previewLayout(.sizeThatFits)
    }
}

extension GridLayoutViewModel {
    static func stub(onscreenSpeakerCount: Int = 6, offscreenSpeakerCount: Int = 0) -> GridLayoutViewModel {
        let viewModel = GridLayoutViewModel()

        viewModel.onscreenSpeakers = Array(1...onscreenSpeakerCount)
            .map { ParticipantViewModel.stub(identity: "Speaker \($0)") }
        
        if offscreenSpeakerCount > 1 {
            viewModel.offscreenSpeakers = Array(1...offscreenSpeakerCount)
                .map { ParticipantViewModel.stub(identity: "Offscreen \($0)") }
        }
        
        return viewModel
    }
}
