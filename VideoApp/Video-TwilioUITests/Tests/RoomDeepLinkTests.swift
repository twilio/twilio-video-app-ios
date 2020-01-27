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

import Nimble
import XCTest

class RoomDeepLinkTests: UITestCase {
    func testWhenSignedIn() {
        AuthActivities.signIn()
        DeepLinkActivities.open(url: "https://twilio-video-react.appspot.com/room/foo")
        expect(self.app.textFields["roomNameTextField"].value as? String).toEventually(equal("foo"))
        AuthActivities.signOut()
    }

    func testWhenSignedOut() {
        DeepLinkActivities.open(url: "https://twilio-video-react.appspot.com/room/foo")
        AuthActivities.signIn()
        expect(self.app.textFields["roomNameTextField"].value as? String).toEventually(equal("foo"))
        AuthActivities.signOut()
    }
}
