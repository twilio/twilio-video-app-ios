//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct CardButtonLabel: View {
    let title: String
    let image: Image
    var detail: String?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .foregroundColor(.white)
                .shadow(color: .shadowLow, radius: 8, x: 0, y: 2)
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.borderWeaker, lineWidth: 1)
            
            HStack(alignment: .titleAndImages) {
                ZStack {
                    Color.backgroundPrimaryWeakest
                        .clipShape(Circle())
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(10)
                        .foregroundColor(Color.backgroundPrimary)
                        .alignmentGuide(.titleAndImages) { $0[VerticalAlignment.center] }
                }
                .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .fontWeight(.bold)
                        .alignmentGuide(.titleAndImages) { $0[VerticalAlignment.center] }
                        .multilineTextAlignment(.leading)

                    if let detail = detail {
                        Text(detail)
                            .multilineTextAlignment(.leading)
                            .font(.system(size: 13))
                    }
                }
                .foregroundColor(.textWeak)

                Spacer()
                Image(systemName: "arrow.right")
                    .foregroundColor(.backgroundPrimary)
                    .font(.system(size: 20, weight: .medium))
                    .padding(.trailing, 8)
                    .alignmentGuide(.titleAndImages) { $0[VerticalAlignment.center] }
            }
            .padding(16)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

// https://developer.apple.com/documentation/swiftui/aligning-views-across-stacks
private extension VerticalAlignment {
    private struct TitleAndImages: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[VerticalAlignment.center]
        }
    }

    static let titleAndImages = VerticalAlignment(TitleAndImages.self)
}

struct CardButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardButtonLabel(
                title: "Title",
                image: Image(systemName: "mic")
            )
                .previewDisplayName("Default Image Color")
            
            CardButtonLabel(
                title: String(repeating: "Title ", count: 10),
                image: Image(systemName: "mic")
            )
                .previewDisplayName("Long Title")
            
            CardButtonLabel(
                title: "Title",
                image: Image(systemName: "mic"),
                detail: String(repeating: "Detail ", count: 20)
            )
                .previewDisplayName("Detail")
            
            CardButtonLabel(
                title: String(repeating: "Title ", count: 10),
                image: Image(systemName: "mic"),
                detail: String(repeating: "Detail ", count: 20)
            )
                .previewDisplayName("Long Title with Detail")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
