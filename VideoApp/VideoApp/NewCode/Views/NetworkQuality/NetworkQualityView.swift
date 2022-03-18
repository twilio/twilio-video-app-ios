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
import TwilioVideo

struct NetworkQualityView: View {
    let level: NetworkQualityLevel
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: geometry.size.width / 20) {
                ForEach(1...5, id: \.self) { index in
                    Rectangle()
                        .frame(height: geometry.size.height * 0.2 * CGFloat(index))
                        .foregroundColor(.white)
                        .opacity(index <= level.rawValue ? 1 : 0.2)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct NetworkQualityView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(0...5, id: \.self) { index in
            NetworkQualityView(level: NetworkQualityLevel(rawValue: index)!)
                .previewDisplayName("\(index) bars")
        }
        .frame(width: 50)
        .background(Color.roomBackground)
        .previewLayout(.sizeThatFits)
    }
}
