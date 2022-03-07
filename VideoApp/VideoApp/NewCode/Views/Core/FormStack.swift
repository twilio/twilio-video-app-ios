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

struct FormStack<Content>: View where Content: View {
    private let spacing: CGFloat
    private let content: () -> Content
    
    init(spacing: CGFloat = 30, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: spacing) {
                    content()
                    Spacer()
                }
                .padding(.top, 20)
                .padding([.horizontal, .bottom], 40)
            }
        }
    }
}

struct FormView_Previews: PreviewProvider {
    static var previews: some View {
        FormStack {
            TextField("Text field", text: .constant(""))
                .textFieldStyle(FormTextFieldStyle())
            Button("Button") {

            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
}
