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

struct ParticipantView: View {
    @Binding var viewModel: ParticipantViewModel
    
    var body: some View {
        ZStack {
            Color.backgroundStronger
            Text(viewModel.displayName)
                .lineLimit(3)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .font(.system(size: 24, weight: .bold))
                .padding()

            if viewModel.cameraTrack != nil {
                SwiftUIVideoView(videoTrack: $viewModel.cameraTrack, shouldMirror: $viewModel.shouldMirrorCameraVideo)
            }

            VStack {
                HStack {
                    Spacer()
                    
                    if viewModel.isMuted {
                        Image(systemName: "mic.slash")
                            .foregroundColor(.white)
                            .padding(9)
                            .background(Color.backgroundBrandStronger.opacity(0.4))
                            .clipShape(Circle())
                            .padding(8)
                    }
                }
                Spacer()
                HStack(alignment: .bottom) {
                    Text(viewModel.displayName)
                        .lineLimit(1)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.backgroundBrandStronger.opacity(0.7))
                        .cornerRadius(2)
                        .font(.system(size: 14))
                    Spacer()
                }
                .padding(4)
            }

            VStack {
                if viewModel.isDominantSpeaker {
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.borderSuccessWeak, lineWidth: 4)
                }
            }
        }
        .cornerRadius(3)
    }
}

struct ParticipantView_Previews: PreviewProvider {
    static var previews: some View {
        let longIdentity = String(repeating: "Long ", count: 20)
        
        Group {
            ParticipantView(viewModel: .constant(ParticipantViewModel.stub()))
                .previewDisplayName("Not muted")
            ParticipantView(viewModel: .constant(ParticipantViewModel.stub(identity: longIdentity)))
                .previewDisplayName("Long display name")
            ParticipantView(viewModel: .constant(ParticipantViewModel.stub(isMuted: true)))
                .previewDisplayName("Muted")
            ParticipantView(viewModel: .constant(ParticipantViewModel.stub(isDominantSpeaker: true)))
                .previewDisplayName("Dominant speaker")
        }
        .frame(width: 200, height: 200)
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

extension ParticipantViewModel {
    static func stub(
        identity: String = "Alice",
        isMuted: Bool = false,
        isDominantSpeaker: Bool = false
    ) -> ParticipantViewModel {
        var viewModel = ParticipantViewModel()
        viewModel.isMuted = isMuted
        viewModel.identity = identity
        viewModel.displayName = identity
        viewModel.isDominantSpeaker = isDominantSpeaker
        return viewModel
    }
}
