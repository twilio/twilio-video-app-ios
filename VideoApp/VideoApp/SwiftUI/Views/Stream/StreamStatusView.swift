//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct StreamStatusView: View {
    let streamName: String
    @Binding var streamState: StreamManager.State
    
    var body: some View {
        HStack {
            Text(streamName)
                .foregroundColor(.white)
                .font(.system(size: 16))
                .lineLimit(1)
            Spacer(minLength: 20)
        }
        .background(Color.backgroundBrandStronger)
    }
}

struct StreamStatusView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StreamStatusView(streamName: "Short room name", streamState: .constant(.connected))
                .previewDisplayName("Short Room Name")
            StreamStatusView(
                streamName: "A very long room name that does not fit and is truncated",
                streamState: .constant(.connected)
            )
                .previewDisplayName("Long Room Name")
        }
        .previewLayout(.sizeThatFits)
    }
}
