//
//  SampleBufferVideoCallView.swift
//  VideoApp
//
//  Created by Tim Rozum on 7/14/22.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import AVKit
import SwiftUI
import UIKit
import TwilioVideo

struct SwiftUITestView: UIViewRepresentable {
    func makeUIView(context: Context) -> some SampleBufferVideoCallView {
        return SampleBufferVideoCallView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {

    }
}


class SampleBufferVideoCallView: UIView {
    override class var layerClass: AnyClass {
        AVSampleBufferDisplayLayer.self
    }
    
    var sampleBufferDisplayLayer: AVSampleBufferDisplayLayer {
        layer as! AVSampleBufferDisplayLayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            guard
                let image = UIImage(named: "code"),
                let pixelBuffer = buffer(from: image)
            else {
                print("convert image error")
                return
            }

            let sampleBuffer = convertCMSampleBuffer(pixelBuffer, width: Int(image.size.width), height: Int(image.size.height))
            
            print("enque image")
            self.sampleBufferDisplayLayer.enqueue(sampleBuffer)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func buffer(from image: UIImage) -> CVPixelBuffer? {
//    let emptyDictionary: [String: Any] = [:]
    
    let attrs = [
        kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue as Any,
    kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue as Any,
    kCVPixelBufferIOSurfacePropertiesKey: [:]
  ] as CFDictionary
  var pixelBuffer : CVPixelBuffer?
  let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
  guard (status == kCVReturnSuccess) else {
    return nil
  }

  CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
  let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

  let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
  let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

  context?.translateBy(x: 0, y: image.size.height)
  context?.scaleBy(x: 1.0, y: -1.0)

  UIGraphicsPushContext(context!)
  image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
  UIGraphicsPopContext()
  CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

  return pixelBuffer
}


func convertCMSampleBuffer(_ cvPixelBuffer: CVPixelBuffer?, width: Int, height: Int) -> CMSampleBuffer {
    
    var pixelBuffer = cvPixelBuffer
    CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, nil, &pixelBuffer)

    var info = CMSampleTimingInfo()
    info.presentationTimeStamp = CMTime.zero
    info.duration = CMTime.invalid
    info.decodeTimeStamp = CMTime.invalid

    var formatDesc: CMFormatDescription?
    CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                                 imageBuffer: pixelBuffer!,
                                                 formatDescriptionOut: &formatDesc)

    var sampleBuffer: CMSampleBuffer?

    CMSampleBufferCreateReadyWithImageBuffer(allocator: kCFAllocatorDefault,
                                             imageBuffer: pixelBuffer!,
                                             formatDescription: formatDesc!,
                                             sampleTiming: &info,
                                             sampleBufferOut: &sampleBuffer)

    return sampleBuffer!
}




class PictureInPictureControllerStorage {
    static let shared = PictureInPictureControllerStorage()
    
    var controller: AVPictureInPictureController?
    var videoRenderer: VideoRenderer!
}



struct PictureInPictureSourceView: UIViewRepresentable {

    func makeUIView(context: Context) -> UIView {
        let emptyView = UIView()
        emptyView.backgroundColor = .purple
        
        
        let pipVideoCallViewController = AVPictureInPictureVideoCallViewController()
        pipVideoCallViewController.preferredContentSize = CGSize(width: 1080, height: 1920)

//        let sampleBufferVideoCallView = SampleBufferVideoCallView()
        let sampleBufferVideoCallView = ExampleSampleBufferView(
            frame: CGRect(x: 0, y: 0, width: 500, height: 500)
        )
        sampleBufferVideoCallView.contentMode = .scaleAspectFit
        
        sampleBufferVideoCallView.bounds = pipVideoCallViewController.view.frame
        
//        let blueView = UIView(frame: CGRect(x: 0, y: 0, width: 1070, height: 1900))
//        blueView.backgroundColor = .blue
        pipVideoCallViewController.view.addSubview(sampleBufferVideoCallView)
//        pipVideoCallViewController.view.addSubview(blueView)

        let pipContentSource = AVPictureInPictureController.ContentSource(
            activeVideoCallSourceView: emptyView,
            contentViewController: pipVideoCallViewController
        )
        
        print("PIP support: \(AVPictureInPictureController.isPictureInPictureSupported())")
        
        let pipController = AVPictureInPictureController(contentSource: pipContentSource)
        pipController.canStartPictureInPictureAutomaticallyFromInline = true
        pipController.delegate = context.coordinator

        PictureInPictureControllerStorage.shared.controller = pipController
        PictureInPictureControllerStorage.shared.videoRenderer = sampleBufferVideoCallView

        return emptyView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {

    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: ()) {
        PictureInPictureControllerStorage.shared.controller = nil
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    class Coordinator: NSObject, AVPictureInPictureControllerDelegate {

        func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
            print("TCR started pip")
        }
        
        func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
            print("TCR failed to start pip")
        }
        
        func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
            print("TCR stopped pip")
        }
    }
}


