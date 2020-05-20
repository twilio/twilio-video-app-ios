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

class RemoteVideoTrack: VideoTrack {
    var isSwitchedOff: Bool { track.isSwitchedOff }
    var isEnabled: Bool { track.isEnabled }
    var priority: Track.Priority? {
        get {
            track.priority
        }
        set {
            guard newValue != priority else { return }

            track.priority = newValue
        }
    }
    var renderers: [VideoRenderer] { track.renderers }
    private let track: TwilioVideo.RemoteVideoTrack

    init(track: TwilioVideo.RemoteVideoTrack) {
        self.track = track
    }

    func addRenderer(_ renderer: VideoRenderer) {
        track.addRenderer(renderer)
    }

    func removeRenderer(_ renderer: VideoRenderer) {
        track.removeRenderer(renderer)
    }
}
