//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct RoomToolbar<Content>: View where Content: View {
    private let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        HStack(spacing: 10) {
            Spacer()
            content()
            Spacer()
        }
        .background(Color.background)
    }
}

struct RoomToolbar_Previews: PreviewProvider {
    static var previews: some View {
        RoomToolbar {
            RoomToolbarButton(image: Image(systemName: "arrow.left"), role: .destructive)
            RoomToolbarButton(image: Image(systemName: "mic.fill"))
        }
        .previewLayout(.sizeThatFits)
    }
}
