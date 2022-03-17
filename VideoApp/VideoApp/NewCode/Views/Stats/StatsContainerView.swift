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

struct StatsContainerView: View {
    @EnvironmentObject var roomManager: RoomManager
    @Binding var isShowingStats: Bool

    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer(minLength: geometry.size.width * 0.15)
                
                VStack(spacing: 0) {
                    HStack {
                        Button(
                            action: {
                                isShowingStats = false
                            },
                            label: {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(10)
                                    .frame(height: 44)
                                    .foregroundColor(.white)
                            }
                        )
                        
                        Spacer()
                    }
                    .background(Color.black.opacity(0.55))
                    
                    StatsView(room: $roomManager.room)
                }
                .padding(.vertical, geometry.size.height * 0.1)
            }
            .ignoresSafeArea()
            
            /// Use opacity to hide the view so that it stays in the view hierarchy. `StatsViewController` is old code
            /// that expects to stay in memory even when it is not visible.
            .opacity(isShowingStats ? 1 : 0)
        }
    }
}

struct StatsContainerView_Previews: PreviewProvider {
    static var previews: some View {
        StatsContainerView(isShowingStats: .constant(true))
            .environmentObject(RoomManager.stub())
            .background(Color.green.ignoresSafeArea())
    }
}
