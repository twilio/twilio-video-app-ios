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
    private let remoteConfigStore: RemoteConfigStoreReading = RemoteConfigStoreFactory().makeRemoteConfigStore()
    
    func makeCameraSource() -> CameraSource? {
        let options = CameraSourceOptions() { builder in
            if let scene = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.windowScene {
                builder.orientationTracker = UserInterfaceTracker(scene: scene)
            }
            
            switch self.remoteConfigStore.roomType {
            case .group, .groupSmall:
                // Take a best guess and remove rotation tags using hardware acceleration
                builder.rotationTags = .remove
            case .peerToPeer, .go, .unknown:
                break
            }
        }
        
        return CameraSource(options: options, delegate: nil)
    }
}
