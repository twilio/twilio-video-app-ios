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

import XCTest

class RoomActivities {
    static func join(roomName: String) {
        XCTContext.runActivity(named: "Join room") { _ in
            let roomNameTextField = app/*@START_MENU_TOKEN@*/.textFields["roomNameTextField"]/*[[".textFields[\"Room\"]",".textFields[\"roomNameTextField\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
            roomNameTextField.tap()
            roomNameTextField.typeText(roomName)

            app.buttons["joinRoomButton"].tap()
        }
    }

    static func leave() {
        XCTContext.runActivity(named: "Leave room") { _ in
            app.buttons["leaveRoomButton"].tap()
        }
    }
}
