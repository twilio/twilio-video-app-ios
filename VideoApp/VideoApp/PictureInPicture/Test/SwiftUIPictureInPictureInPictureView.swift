//
//  SwiftUIPictureInPictureInPictureView.swift
//  VideoApp
//
//  Created by Tim Rozum on 8/8/22.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import SwiftUI

struct SwiftUIPictureInPictureView: UIViewControllerRepresentable {
    @EnvironmentObject var callManager: CallManager
    @EnvironmentObject var roomManager: RoomManager
    
    func makeUIViewController(context: Context) -> PictureInPictureViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PictureInPictureViewController") as! PictureInPictureViewController
        controller.callManager = callManager
        controller.roomManager = roomManager
        return controller
    }

    func updateUIViewController(_ uiViewController: PictureInPictureViewController, context: Context) {

    }
}
