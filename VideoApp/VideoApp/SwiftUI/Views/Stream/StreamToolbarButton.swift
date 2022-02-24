//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct StreamToolbarButton: View {
    struct Role {
        let imageForegroundColor: Color
        let imageBackgroundColor: Color
        
        static let `default` = Role(
            imageForegroundColor: .backgroundStrongest,
            imageBackgroundColor: .backgroundStrong
        )
        static let highlight = Role(
            imageForegroundColor: .white,
            imageBackgroundColor: .backgroundHighlight
        )
        static let destructive = Role(
            imageForegroundColor: .white,
            imageBackgroundColor: .backgroundDestructive
        )
    }
    
    let image: Image
    let role: Role
    let shouldShowBadge: Bool
    let action: () -> Void
    
    init(
        image: Image,
        role: Role = .default,
        shouldShowBadge: Bool = false,
        action: @escaping () -> Void = { }
    ) {
        self.image = image
        self.role = role
        self.shouldShowBadge = shouldShowBadge
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action()
        }) {
            VStack(spacing: 4) {
                ZStack {
                    role.imageBackgroundColor
                        .clipShape(Circle())
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(10)
                        .foregroundColor(role.imageForegroundColor)

                    if shouldShowBadge {
                        HStack {
                            Spacer()
                            VStack {
                                ZStack {
                                    Circle()
                                        .foregroundColor(.background)
                                    Circle()
                                        .foregroundColor(.backgroundDestructive)
                                        .padding(2)
                                }
                                .frame(width: 12, height: 12)
                                .padding(1)
                                
                                Spacer()
                            }
                        }
                    }
                }
                .frame(width: 44, height: 44)
            }
            .padding(.top, 14)
            .frame(width: 60)
            .foregroundColor(.backgroundStrongest)
        }
    }
}

struct StreamToolbarButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StreamToolbarButton(image: Image(systemName: "mic.slash"))
                .previewDisplayName("Default")
            StreamToolbarButton(image: Image(systemName: "hand.raised"), role: .highlight)
                .previewDisplayName("Highlight")
            StreamToolbarButton(image: Image(systemName: "person.2"), shouldShowBadge: true)
                .previewDisplayName("Badge")
            StreamToolbarButton(image: Image(systemName: "arrow.left"), role: .destructive)
                .previewDisplayName("Destructive")
        }
        .previewLayout(.sizeThatFits)
        .background(Color.background)
    }
}
