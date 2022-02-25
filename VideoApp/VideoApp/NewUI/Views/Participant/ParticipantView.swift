//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct ParticipantView: View {
    @Binding var speaker: ParticipantViewModel // TODO: Rename to participant from speaker
    
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

struct ParticipantView_Previews: PreviewProvider {
    static var previews: some View {
        let longIdentity = String(repeating: "Long ", count: 20)
        
        Group {
            ParticipantView(speaker: .constant(ParticipantViewModel()))
                .previewDisplayName("Not muted")
            ParticipantView(speaker: .constant(ParticipantViewModel(identity: longIdentity)))
                .previewDisplayName("Long identity")
            ParticipantView(speaker: .constant(ParticipantViewModel(identity: longIdentity)))
                .previewDisplayName("Long identity without host controls")
            ParticipantView(speaker: .constant(ParticipantViewModel(isMuted: true)))
                .previewDisplayName("Muted")
            ParticipantView(speaker: .constant(ParticipantViewModel(isDominantSpeaker: true)))
                .previewDisplayName("Dominant speaker")
        }
        .frame(width: 200, height: 200)
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

// TODO: Move this...I think it's used in real production code
import TwilioVideo

extension ParticipantViewModel {
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
