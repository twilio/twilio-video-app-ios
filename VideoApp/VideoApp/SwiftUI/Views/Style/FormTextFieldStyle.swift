//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct FormTextFieldStyle: TextFieldStyle {
    private let cornerRadius: CGFloat = 3
    
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding(10)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.white)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(Color.border)
                }
            )
    }
}
