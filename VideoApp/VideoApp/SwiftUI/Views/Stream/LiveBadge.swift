//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct LiveBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "dot.radiowaves.left.and.right")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 12)
            Text("Live")
                .fixedSize()
                .font(.system(size: 13))
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .foregroundColor(.black)
        .background(Color.backgroundLiveBadge)
        .cornerRadius(2)
    }
}

struct LiveBadge_Previews: PreviewProvider {
    static var previews: some View {
        LiveBadge()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
