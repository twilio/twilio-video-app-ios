//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct RoomStatusView: View {
    let streamName: String
    
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

struct RoomStatusView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RoomStatusView(streamName: "Short room name")
                .previewDisplayName("Short room name")
            RoomStatusView(streamName: "A very long room name that does not fit and is truncated")
                .previewDisplayName("Long room name")
        }
        .frame(width: 400)
        .previewLayout(.sizeThatFits)
    }
}
