//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI
import TwilioVideo

struct PresentationVideoView: View {
    @Binding var videoTrack: VideoTrack?

    var body: some View {
        ZStack {
            Color.black
            SwiftUIVideoView(videoTrack: $videoTrack, shouldMirror: .constant(false), fill: false)
        }
        .cornerRadius(4)
    }
}

struct PresentationVideoView_Previews: PreviewProvider {
    static var previews: some View {
        PresentationVideoView(videoTrack: .constant(nil))
            .frame(height: 400)
            .previewLayout(.sizeThatFits)
    }
}
