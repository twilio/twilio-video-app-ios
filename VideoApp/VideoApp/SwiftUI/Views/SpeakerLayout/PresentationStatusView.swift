//
//  Copyright (C) 2022 Twilio, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import SwiftUI

struct PresentationStatusView: View {
    let presenterIdentity: String
    
    var body: some View {
        ZStack {
            Color.backgroundInverseStrong
            Text(presenterIdentity + " is presenting.")
                .foregroundColor(.white)
                .font(.system(size: 13, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(8)
        }
        .cornerRadius(4)
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct PresentationStatusView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PresentationStatusView(presenterIdentity: "Alice")
                .previewDisplayName("Short name")
            PresentationStatusView(presenterIdentity: "Someone with a long name that doesn't fit on one line")
                .previewDisplayName("Long name")
        }
        .previewLayout(.sizeThatFits)
    }
}
