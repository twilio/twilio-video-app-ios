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

struct MediaSetupView: View {
    @EnvironmentObject var viewModel: MediaSetupViewModel
    @EnvironmentObject var localParticipant: LocalParticipantManager
    @Environment(\.presentationMode) var presentationMode
    let roomName: String
    @Binding var isMediaSetup: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()

                VStack {
                    Text("Join " + roomName)
                        .font(.title2)
                    
                    ParticipantView(viewModel: $viewModel.participant)
                        .aspectRatio(1, contentMode: .fit)
                        .padding(.horizontal, 70)
                        .padding(.vertical)

                    HStack {
                        Spacer()
                        MicToggleButton()
                        CameraToggleButton()
                        Spacer()
                    }
                    
                    Spacer()
                    Spacer()
                    
                    Button("Join Now") {
                        isMediaSetup = true
                        presentationMode.wrappedValue.dismiss()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 40)

                    Spacer()
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                isMediaSetup = false
                localParticipant.isMicOn = true
                localParticipant.isCameraOn = true
            }
            .onDisappear {
                // Is called for cancel button and swipe dismiss gesture
                if !isMediaSetup {
                    localParticipant.isMicOn = false
                    localParticipant.isCameraOn = false
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct MediaSetupView_Previews: PreviewProvider {
    static var previews: some View {
        MediaSetupView(roomName: "Demo", isMediaSetup: .constant(true))
            .environmentObject(MediaSetupViewModel.stub())
            .environmentObject(LocalParticipantManager.stub())
    }
}

extension MediaSetupViewModel {
    static func stub() -> MediaSetupViewModel {
        let viewModel = MediaSetupViewModel()
        viewModel.participant = ParticipantViewModel.stub(networkQualityLevel: .unknown)
        return viewModel
    }
}
