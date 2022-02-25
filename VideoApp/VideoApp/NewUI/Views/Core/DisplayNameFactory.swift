//
//  Copyright (C) 2022 Twilio, Inc.
//

import Foundation

// TODO: Rename to something "user"
class DisplayNameFactory {
    func makeDisplayName(identity: String, isYou: Bool = false) -> String {
        isYou ? "You" : identity
    }
}
