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

struct CameraConfig {
    let outputFormat: VideoFormat
    let inputFormat: VideoFormat
}

class CameraConfigFactory {
    private let appSettingsStore: AppSettingsStoreWriting = AppSettingsStore.shared
    
    func makeCameraConfigFactory(captureDevice: AVCaptureDevice) -> CameraConfig {
        let targetSize: CMVideoDimensions
        let cropRatio: CGFloat
        let frameRate: UInt
        
        switch appSettingsStore.videoCodec {
        case .h264, .vp8:
            // 640 x 480 squarish crop (1.13:1)
            targetSize = CMVideoDimensions(width: 544, height: 480)
            
            cropRatio = CGFloat(targetSize.width) / CGFloat(targetSize.height)
            frameRate = 20
        case .vp8Simulcast:
            // 1024 x 768 squarish crop (1.25:1) on most iPhones. 1280 x 720 squarish crop (1.25:1) on the iPhone X
            // and models that don't have 1024 x 768.
            targetSize = CMVideoDimensions(width: 900, height: 720)
            
            cropRatio = CGFloat(targetSize.width) / CGFloat(targetSize.height)
            frameRate = 24 // With simulcast enabled there are 3 temporal layers, allowing a frame rate of f/4
        }
        
        let preferredFormat = selectVideoFormatBySize(captureDevice: captureDevice, targetSize: targetSize)
        preferredFormat.frameRate = min(preferredFormat.frameRate, frameRate)
        
        let cropDimensions: CMVideoDimensions
        
        if preferredFormat.dimensions.width > preferredFormat.dimensions.height {
            cropDimensions = CMVideoDimensions(
                width: Int32(CGFloat(preferredFormat.dimensions.height) * cropRatio),
                height: preferredFormat.dimensions.height
            )
        } else {
            cropDimensions = CMVideoDimensions(
                width: preferredFormat.dimensions.width,
                height: Int32(CGFloat(preferredFormat.dimensions.width) * cropRatio)
            )
        }
        
        let outputFormat = VideoFormat()
        outputFormat.dimensions = cropDimensions
        outputFormat.pixelFormat = preferredFormat.pixelFormat
        outputFormat.frameRate = 0

        return CameraConfig(outputFormat: outputFormat, inputFormat: preferredFormat)
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
