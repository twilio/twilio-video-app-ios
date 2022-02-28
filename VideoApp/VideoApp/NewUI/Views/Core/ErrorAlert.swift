//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

extension Alert {
    init(error: Error, action: (() -> Void)? = nil) {
        self.init(
            title: Text("Error"),
            message: Text(error.localizedDescription),
            dismissButton: .default(Text("OK")) {
                action?()
            }
        )
    }
}
