//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

/// Displays participants in a video grid layout.
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
            return (viewModel.onscreenParticipants.count + viewModel.onscreenParticipants.count % columnCount) / columnCount
        } else {
            return viewModel.onscreenParticipants.count < 5 ? 1 : 2
        }
    }
    
    private var columnCount: Int {
        if isPortraitOrientation {
            return viewModel.onscreenParticipants.count < 4 ? 1 : 2
        } else {
            return (viewModel.onscreenParticipants.count + viewModel.onscreenParticipants.count % rowCount) / rowCount
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
            if viewModel.onscreenParticipants.isEmpty {
                Spacer()
            } else {
                GeometryReader { geometry in
                    LazyVGrid(columns: columns, spacing: spacing) {
                        ForEach($viewModel.onscreenParticipants, id: \.self) { $speaker in
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
    static func stub(onscreenSpeakerCount: Int = 6) -> GridLayoutViewModel {
        let viewModel = GridLayoutViewModel()

        viewModel.onscreenParticipants = Array(1...onscreenSpeakerCount)
            .map { ParticipantViewModel.stub(identity: "Participant \($0)") }
        
        return viewModel
    }
}
