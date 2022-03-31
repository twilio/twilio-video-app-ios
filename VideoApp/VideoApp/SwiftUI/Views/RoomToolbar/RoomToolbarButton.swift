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

struct RoomToolbarButton: View {
    struct Role {
        let imageForegroundColor: Color
        let imageBackgroundColor: Color
        
        static let `default` = Role(
            imageForegroundColor: .backgroundStrongest,
            imageBackgroundColor: .backgroundStrong
        )
        static let destructive = Role(
            imageForegroundColor: .white,
            imageBackgroundColor: .backgroundDestructive
        )
    }
    
    let image: Image
    let role: Role
    let action: () -> Void
    
    init(image: Image, role: Role = .default, action: @escaping () -> Void = { }) {
        self.image = image
        self.role = role
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action()
        }) {
            ZStack {
                role.imageBackgroundColor
                    .clipShape(Circle())
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(10)
                    .foregroundColor(role.imageForegroundColor)
            }
            .frame(width: 44, height: 44)
            .padding(.top, 14)
            .frame(width: 60)
            .foregroundColor(.backgroundStrongest)
        }
    }
}

struct RoomToolbarButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RoomToolbarButton(image: Image(systemName: "suit.heart"))
                .previewDisplayName("Default")
            RoomToolbarButton(image: Image(systemName: "suit.club"), role: .destructive)
                .previewDisplayName("Destructive")
        }
        .previewLayout(.sizeThatFits)
        .background(Color.background)
    }
}
