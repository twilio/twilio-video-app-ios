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

struct ProgressHUD: View {
    var title: String?
    
    var body: some View {
        ZStack {
            Color.backgroundBodyInverse
                .opacity(0.6)
            VStack(spacing: 40) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .green))
                    .scaleEffect(2)
                
                if let title = title {
                    Text(title)
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold))
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct ProgressHUD_Previews: PreviewProvider {
    static var previews: some View {
        ProgressHUD(title: "Title")
        ProgressHUD()
    }
}
