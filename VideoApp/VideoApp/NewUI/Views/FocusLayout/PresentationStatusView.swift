//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI

struct PresentationStatusView: View {
    let presenterIdentity: String
    
    var body: some View {
        ZStack {
            Color.backgroundBrand
            Text(presenterIdentity + " is presenting.")
                .foregroundColor(.white)
                .font(.system(size: 13, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(8)
        }
        .cornerRadius(4)
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct PresentationStatusView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PresentationStatusView(presenterIdentity: "Alice")
                .previewDisplayName("Short name")
            PresentationStatusView(presenterIdentity: "Someone with a long name that doesn't fit on one line")
                .previewDisplayName("Long name")
        }
        .previewLayout(.sizeThatFits)
    }
}
