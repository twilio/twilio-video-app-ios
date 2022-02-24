//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct TipStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.textWeak)
            .font(.system(size: 15))
    }
}
