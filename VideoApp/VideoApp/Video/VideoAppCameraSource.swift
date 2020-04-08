//
//  Copyright (C) 2020 Twilio, Inc.
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

import TwilioVideo

@objc class VideoAppCameraSource: NSObject, VideoAppCamera {
    private(set) var localVideoTrack: LocalVideoTrack?
    private let appSettingsStore: AppSettingsStoreWriting = AppSettingsStore.shared
    private weak var localMediaController: LocalMediaController!
    private var cameraSource: CameraSource?
    private var videoCodec: VideoCodec { appSettingsStore.videoCodec }

    @objc init(localMediaController: LocalMediaController) {
        self.localMediaController = localMediaController
        super.init()
        createCameraSource()
    }
    
    deinit {
        cameraSource?.stopCapture() // Prevent leaking the CameraSource when a Track/Source has been created
    }

    func destroyLocalVideoTrack() {
        cameraSource?.stopCapture() { [weak self] _ in
            self?.localVideoTrack = nil
            self?.cameraSource = nil
        }
    }

    func flip(_ isMultiparty: Bool) {
        guard
            let cameraSource = cameraSource,
            let position = cameraSource.device?.position,
            let captureDevice = CameraSource.captureDevice(position: position == .front ? .back : .front)
            else {
                return
        }

        let format = selectVideoFormat(captureDevice: captureDevice, isMultiparty: false)

        cameraSource.selectCaptureDevice(captureDevice, format: format) { [weak self] _, _, error in
            guard error == nil else { return }
            
            self?.localMediaController.videoCaptureStarted()
        }
    }

    func shouldMirrorLocalVideoView() -> Bool {
        localVideoTrack?.shouldMirror ?? false
    }
    
    func updateVideoSenderSettings(_ isMultiparty: Bool) {
        guard let cameraSource = cameraSource, let device = cameraSource.device else { return }
        
        let format = selectVideoFormat(captureDevice: device, isMultiparty: isMultiparty)
        cameraSource.selectCaptureDevice(device, format: format, completion: nil)
    }
    
    private func createCameraSource() {
        let options = CameraSourceOptions() { builder in
            if #available(iOS 13, *) {
                builder.orientationTracker = UserInterfaceTracker(scene: UIApplication.shared.keyWindow!.windowScene!)
            }
            
            switch self.appSettingsStore.topology {
            case .group:
                // Take a best guess and remove rotation tags using hardware acceleration
                builder.rotationTags = .remove
            case .peerToPeer:
                break
            }
        }
        
        cameraSource = CameraSource(options: options, delegate: self)
        
        if let cameraSource = cameraSource {
            localVideoTrack = LocalVideoTrack(source: cameraSource, enabled: true, name: "camera")
            startCameraSource()
        }
    }
    
    private func startCameraSource() {
        guard let cameraSource = cameraSource else { return }

        let captureDevice = CameraSource.captureDevice(position: .front)!
        let preferredFormat = selectVideoFormat(captureDevice: captureDevice, isMultiparty: false)
        
        let cropDimensions: CMVideoDimensions
        
        if preferredFormat.dimensions.width > preferredFormat.dimensions.height {
            cropDimensions = CMVideoDimensions(
                width: Int32(CGFloat(preferredFormat.dimensions.height) * videoCodec.cropRatio),
                height: preferredFormat.dimensions.height
            )
        } else {
            cropDimensions = CMVideoDimensions(
                width: preferredFormat.dimensions.width,
                height: Int32(CGFloat(preferredFormat.dimensions.width) * videoCodec.cropRatio)
            )
        }
        
        let outputFormat = VideoFormat()
        outputFormat.dimensions = cropDimensions
        outputFormat.pixelFormat = preferredFormat.pixelFormat
        outputFormat.frameRate = 0
        
        cameraSource.requestOutputFormat(outputFormat)
        
        cameraSource.startCapture(device: captureDevice, format: preferredFormat) { [weak self] _, _, error in
            guard error == nil else { return }
            
            self?.localMediaController.videoCaptureStarted()
        }
    }

    private func selectVideoFormat(captureDevice: AVCaptureDevice, isMultiparty: Bool) -> VideoFormat {
        let format = selectVideoFormatBySize(captureDevice: captureDevice, targetSize: videoCodec.targetSize)
        format.frameRate = videoCodec.frameRate(isMultiparty: isMultiparty)
        return format
    }

    private func selectVideoFormatBySize(captureDevice: AVCaptureDevice, targetSize: CMVideoDimensions) -> VideoFormat {
        let supportedFormats = Array(CameraSource.supportedFormats(captureDevice: captureDevice)) as! [VideoFormat]
        
        // Cropping might be used if there is not an exact match
        for format in supportedFormats {
            guard
                format.pixelFormat == .formatYUV420BiPlanarFullRange &&
                    format.dimensions.width >= targetSize.width &&
                    format.dimensions.height >= targetSize.height
                else {
                    continue
            }
            
            return format
        }
        
        fatalError()
    }
}

extension VideoAppCameraSource: CameraSourceDelegate {
    func cameraSourceInterruptionEnded(source: CameraSource) {
        localMediaController.cameraSourceInterruptionEnded()
    }

    func cameraSourceWasInterrupted(source: CameraSource, reason: AVCaptureSession.InterruptionReason) {
        localMediaController.cameraSourceWasInterrupted()
    }
}

private extension VideoCodec {
    var targetSize: CMVideoDimensions {
        switch self {
        case .h264, .vp8:
            // 640 x 480 squarish crop (1.13:1)
            return CMVideoDimensions(width: 544, height: 480)
        case .vp8Simulcast:
            // 1024 x 768 squarish crop (1.25:1) on most iPhones. 1280 x 720 squarish crop (1.25:1) on the iPhone X
            // and models that don't have 1024 x 768.
            return CMVideoDimensions(width: 900, height: 720)
        }
    }
    var cropRatio: CGFloat { CGFloat(targetSize.width) / CGFloat(targetSize.height) }
    
    func frameRate(isMultiparty: Bool) -> UInt {
        switch self {
        case .h264, .vp8: return 20
        case .vp8Simulcast: return isMultiparty ? 15 : 24 // With simulcast enabled there are 3 temporal layers, allowing a frame rate of f/4
        }
    }
}
