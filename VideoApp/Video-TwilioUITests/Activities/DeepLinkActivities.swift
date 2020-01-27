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

// Inspired by https://blog.branch.io/ui-testing-universal-links-in-xcode-9/
class DeepLinkActivities {
    static func open(url: String) {
        let messagesApp = XCUIApplication(bundleIdentifier: "com.apple.MobileSMS")

        XCTContext.runActivity(named: "Launch Messages app") { _ in
            messagesApp.launch()
            expect(messagesApp.exists).toEventually(beTrue())
            
            XCTContext.runActivity(named: "Tap continue on what's new screen") { _ in
                let continueButton = messagesApp.buttons["Continue"]
                if (continueButton.exists) {
                    continueButton.tap()
                }
            }
            
            XCTContext.runActivity(named: "Tap cancel on new message screen") { _ in
                let cancelButton = messagesApp.navigationBars.buttons["Cancel"]
                if cancelButton.exists {
                    cancelButton.tap()
                }
            }
        }
        
        XCTContext.runActivity(named: "Tap URL") { _ in
            messagesApp.cells.staticTexts["Kate Bell"].tap()
            messagesApp.textFields["iMessage"].tap()
            messagesApp.typeText("Deep link: \(url)")
            messagesApp.buttons["sendButton"].tap()
            sleep(2)
            messagesApp.cells.links["com.apple.messages.URLBalloonProvider"].tap()
        }
        
        sleep(2)
        messagesApp.terminate()
    }
}
