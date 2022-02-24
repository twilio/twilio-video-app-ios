//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct SpeakerVideoView: View {
    @Binding var speaker: SpeakerVideoViewModel
    
    var body: some View {
        ZStack {
            Color.backgroundStronger
            Text(speaker.displayName)
                .lineLimit(3)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .font(.system(size: 24, weight: .bold))
                .padding()

            if speaker.cameraTrack != nil {
                SwiftUIVideoView(videoTrack: $speaker.cameraTrack, shouldMirror: $speaker.shouldMirrorCameraVideo)
            }

            VStack {
                HStack {
                    Spacer()
                    
                    if speaker.isMuted {
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
                    Text(speaker.displayName)
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
                if speaker.isDominantSpeaker {
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.borderSuccessWeak, lineWidth: 4)
                }
            }
        }
        .cornerRadius(3)
    }
}

struct SpeakerVideoView_Previews: PreviewProvider {
    static var previews: some View {
        let longIdentity = String(repeating: "Long ", count: 20)
        
        Group {
            SpeakerVideoView(speaker: .constant(SpeakerVideoViewModel()))
                .previewDisplayName("Not muted")
            SpeakerVideoView(speaker: .constant(SpeakerVideoViewModel(identity: longIdentity)))
                .previewDisplayName("Long identity")
            SpeakerVideoView(speaker: .constant(SpeakerVideoViewModel(identity: longIdentity)))
                .previewDisplayName("Long identity without host controls")
            SpeakerVideoView(speaker: .constant(SpeakerVideoViewModel(isMuted: true)))
                .previewDisplayName("Muted")
            SpeakerVideoView(speaker: .constant(SpeakerVideoViewModel(isDominantSpeaker: true)))
                .previewDisplayName("Dominant speaker")
        }
        .frame(width: 200, height: 200)
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

import TwilioVideo

extension SpeakerVideoViewModel {
    init(
        identity: String = "Alice",
        displayName: String? = nil,
        isYou: Bool = false,
        isMuted: Bool = false,
        isDominantSpeaker: Bool = false,
        dominantSpeakerTimestamp: Date = .distantPast,
        cameraTrack: VideoTrack? = nil,
        shouldMirrorCameraVideo: Bool = false
    ) {
        self.identity = identity
        self.displayName = displayName ?? identity
        self.isYou = isYou
        self.isMuted = isMuted
        self.isDominantSpeaker = isDominantSpeaker
        self.dominantSpeakerStartTime = dominantSpeakerTimestamp
        self.cameraTrack = cameraTrack
        self.shouldMirrorCameraVideo = shouldMirrorCameraVideo
    }
}
