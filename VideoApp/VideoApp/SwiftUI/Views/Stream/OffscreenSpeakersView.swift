//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct OffscreenSpeakersView: View {
    @EnvironmentObject var viewModel: SpeakerGridViewModel
    
    var body: some View {
        ZStack {
            Color.backgroundBrand
                .cornerRadius(4)
            Text("+ \(viewModel.offscreenSpeakers.count) more")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .padding(17)
        }
    }
}

struct OffscreenSpeakersView_Previews: PreviewProvider {
    static var previews: some View {
        OffscreenSpeakersView()
            .environmentObject(SpeakerGridViewModel.stub(offscreenSpeakerCount: 10))
            .previewLayout(.sizeThatFits)
            .fixedSize(horizontal: false, vertical: true)
    }
}
