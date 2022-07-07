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

/// Displays participants in a video grid layout.
struct GalleryLayoutView: View {
    @EnvironmentObject var viewModel: GalleryLayoutViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    let spacing: CGFloat
    private let pageIndexHeight: CGFloat = 40

    private var isPortraitOrientation: Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .compact
    }

    private var gridItemCount: Int {
        viewModel.pages[0].participants.count
    }
    
    private var rowCount: Int {
        if isPortraitOrientation {
            return (gridItemCount + gridItemCount % columnCount) / columnCount
        } else {
            return gridItemCount < 5 ? 1 : 2
        }
    }
    
    private var columnCount: Int {
        if isPortraitOrientation {
            return gridItemCount < 4 ? 1 : 2
        } else {
            return (gridItemCount + gridItemCount % rowCount) / rowCount
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
            if viewModel.pages.isEmpty {
                Spacer()
            } else {
                TabView {
                    ForEach($viewModel.pages, id: \.self) { $page in
                        GeometryReader { geometry in
                            LazyVGrid(columns: columns, spacing: spacing) {
                                ForEach($page.participants, id: \.self) { $participant in
                                    ParticipantView(viewModel: $participant)
                                        .frame(height: geometry.size.height / CGFloat(rowCount) - spacing)
                                }
                            }
                            .padding(.horizontal, spacing)
                        }
                        .padding(.bottom, pageIndexHeight) /// Display the index below the grid
                    }
                }
                .tabViewStyle(PageTabViewStyle())
            }
        }
    }
}

struct GalleryLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        let participantCounts = [1, 2, 3, 4, 5, 6, 7, 100, 0]
        
        Group {
            ForEach(participantCounts, id: \.self) {
                GalleryLayoutView(spacing: 6)
                    .previewDisplayName("Portrait \($0)")
                    .environmentObject(GalleryLayoutViewModel.stub(participantCount: $0))
            }
            .frame(width: 400, height: 700)

            ForEach(participantCounts, id: \.self) {
                GalleryLayoutView(spacing: 6)
                    .previewDisplayName("Landscape \($0)")
                    .environmentObject(GalleryLayoutViewModel.stub(participantCount: $0))
            }
            .frame(width: 700, height: 300)
        }
        .background(Color.roomBackground) // So page index is visible
        .previewLayout(.sizeThatFits)
    }
}

extension GalleryLayoutViewModel {
    static func stub(participantCount: Int = 20) -> GalleryLayoutViewModel {
        let viewModel = GalleryLayoutViewModel()
        
        if participantCount > 0 {
            Array(1...participantCount).forEach { viewModel.addParticipant(.stub(identity: "Participant \($0)")) }
        }
        
        return viewModel
    }
}
