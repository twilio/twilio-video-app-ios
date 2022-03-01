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

protocol CameraManagerDelegate: AnyObject {
    func trackSourceWasInterrupted(track: LocalVideoTrack)
    func trackSourceInterruptionEnded(track: LocalVideoTrack)
}

class CameraManager: NSObject {
    weak var delegate: CameraManagerDelegate?
    let track: LocalVideoTrack
    var position: AVCaptureDevice.Position? {
        get {
            source.device?.position
        }
        set {
            guard let newValue = newValue, let captureDevice = CameraSource.captureDevice(position: newValue) else {
                print("Unable to create capture device."); return
            }
            
            source.selectCaptureDevice(captureDevice) { _, _, error in
                if let error = error {
                    print("Select capture device error: \(error)")
                }
            }
        }
    }
    private let appSettingsStore: AppSettingsStoreWriting = AppSettingsStore.shared
    private let sourceFactory = CameraSourceFactory()
    private let configFactory = CameraConfigFactory()
    private let trackFactory = CameraTrackFactory()
    private let source: CameraSource

    deinit {
        source.stopCapture() // Prevent leaking the CameraSource when a Track/Source has been created
    }

    init?(position: AVCaptureDevice.Position) {
        guard let source = sourceFactory.makeCameraSource() else {
            print("unable to create a capturer."); return nil
        }
        guard let track = trackFactory.makeCameraTrack(source: source) else {
            print("unable to create camera track"); return nil
        }
        guard let captureDevice = CameraSource.captureDevice(position: .front) else {
            print("Unable to create capture device."); return nil
        }
        
        self.source = source
        self.track = track
        super.init()
        source.delegate = self
        
        let config = configFactory.makeCameraConfigFactory(captureDevice: captureDevice)
        
        source.requestOutputFormat(config.outputFormat)
        
        source.startCapture(device: captureDevice, format: config.inputFormat) { _, _, error in
            if let error = error {
                print("Start capture error: \(error)")
            }
        }
    }
}

extension CameraManager: CameraSourceDelegate {
    func cameraSourceWasInterrupted(source: CameraSource, reason: AVCaptureSession.InterruptionReason) {
        delegate?.trackSourceWasInterrupted(track: track)
    }

    func cameraSourceInterruptionEnded(source: CameraSource) {
        delegate?.trackSourceInterruptionEnded(track: track)
    }
}
