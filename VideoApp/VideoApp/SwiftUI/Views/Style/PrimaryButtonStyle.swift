//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(isEnabled ? Color.backgroundPrimary : Color.backgroundPrimaryWeak)
            .foregroundColor(.white)
            .cornerRadius(4.0)
            .font(.body.bold())
     }
}
