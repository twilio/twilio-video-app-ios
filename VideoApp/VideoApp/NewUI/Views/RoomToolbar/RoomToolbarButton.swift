//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct RoomToolbarButton: View {
    struct Role {
        let imageForegroundColor: Color
        let imageBackgroundColor: Color
        
        static let `default` = Role(
            imageForegroundColor: .backgroundStrongest,
            imageBackgroundColor: .backgroundStrong
        )
        static let destructive = Role(
            imageForegroundColor: .white,
            imageBackgroundColor: .backgroundDestructive
        )
    }
    
    let image: Image
    let role: Role
    let action: () -> Void
    
    init(image: Image, role: Role = .default, action: @escaping () -> Void = { }) {
        self.image = image
        self.role = role
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action()
        }) {
            ZStack {
                role.imageBackgroundColor
                    .clipShape(Circle())
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(10)
                    .foregroundColor(role.imageForegroundColor)
            }
            .frame(width: 44, height: 44)
            .padding(.top, 14)
            .frame(width: 60)
            .foregroundColor(.backgroundStrongest)
        }
    }
}

struct RoomToolbarButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RoomToolbarButton(image: Image(systemName: "mic.slash"))
                .previewDisplayName("Default")
            RoomToolbarButton(image: Image(systemName: "arrow.left"), role: .destructive)
                .previewDisplayName("Destructive")
        }
        .previewLayout(.sizeThatFits)
        .background(Color.background)
    }
}
