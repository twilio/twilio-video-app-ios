//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct TitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 28, weight: .bold))
    }
}
