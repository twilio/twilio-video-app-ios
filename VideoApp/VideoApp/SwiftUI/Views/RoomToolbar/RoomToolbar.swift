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

struct RoomToolbar<Content>: View where Content: View {
    private let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        HStack(spacing: 10) {
            Spacer()
            content()
            Spacer()
        }
        .background(Color.background)
    }
}

struct RoomToolbar_Previews: PreviewProvider {
    static var previews: some View {
        RoomToolbar {
            RoomToolbarButton(image: Image(systemName: "suit.heart"), role: .destructive)
            RoomToolbarButton(image: Image(systemName: "suit.club"))
        }
        .previewLayout(.sizeThatFits)
    }
}
