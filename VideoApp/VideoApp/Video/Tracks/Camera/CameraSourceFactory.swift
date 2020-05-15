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

class CameraSourceFactory {
    private let appSettingsStore: AppSettingsStoreWriting = AppSettingsStore.shared
    
    func makeCameraSource() -> CameraSource? {
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
        
        return CameraSource(options: options, delegate: nil)
    }
}
