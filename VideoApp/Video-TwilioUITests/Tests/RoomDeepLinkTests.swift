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

class RoomDeepLinkUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        Nimble.AsyncDefaults.Timeout = 5

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    func testRoomDeepLinkWhenSignedIn() {
        SignIn.signIn()
        
        let messageApp = iMessage.launch()
        iMessage.open(URLString: "https://twilio-video-react.appspot.com/room/standup", inMessageApp: messageApp)
        
        let app = XCUIApplication()
        
        expect(app.textFields["roomNameTextField"].value as? String).toEventually(equal("standup"))

        messageApp.terminate()

        SignIn.signOut()
    }

    func testRoomDeepLinkWhenSignedOut() {
        let messageApp = iMessage.launch()
        iMessage.open(URLString: "https://twilio-video-react.appspot.com/room/standup", inMessageApp: messageApp)
        
        let app = XCUIApplication()

        SignIn.signIn()
        
        expect(app.textFields["roomNameTextField"].value as? String).toEventually(equal("standup"))

        messageApp.terminate()

        SignIn.signOut()
    }
}

//This is based on https://blog.branch.io/ui-testing-universal-links-in-xcode-9/
class iMessage {

    static func launch() -> XCUIApplication {
        // Open iMessage App
        let messageApp = XCUIApplication(bundleIdentifier: "com.apple.MobileSMS")
        
        // Launch iMessage app
        messageApp.launch()
        
        // Wait some seconds for launch
        XCTAssertTrue(messageApp.waitForExistence(timeout: 10))
        
        // Continues "Whats new" if present
        let continueButton = messageApp.buttons["Continue"]
        if (continueButton.exists) {
            continueButton.tap()
        }
        
        // Removes New Messages Sheet on iOS 13
        let cancelButton = messageApp.navigationBars.buttons["Cancel"]
        if cancelButton.exists {
            cancelButton.tap()
        }
        
        // Return application handle
        return messageApp
    }

    static func open(URLString urlString: String, inMessageApp app: XCUIApplication) {
        XCTContext.runActivity(named: "Open URL \(urlString) in iMessage") { _ in
            // Find Simulator Message
            let kateBell = app.cells.staticTexts["Kate Bell"]
            XCTAssertTrue(kateBell.waitForExistence(timeout: 10))
            kateBell.tap()

            // Tap message field
            app.textFields["iMessage"].tap()
                                                                            
            // Continues "Swipe to Text" Sheet
            let continueButton = app.buttons["Continue"]
            if continueButton.exists {
                continueButton.tap()
            }

            // Enter the URL string
            app.typeText("Open Link:\n")
            app.typeText(urlString)

            // Simulate sending link
            app.buttons["sendButton"].tap()

            //Wait for Main App to finish launching
            sleep(2)

            // The first link on the page
            let messageBubble = app.cells.links["com.apple.messages.URLBalloonProvider"]
            XCTAssertTrue(messageBubble.waitForExistence(timeout: 10))
            messageBubble.tap()
        }
    }
}

class SignIn {
    static func signIn() {
        let app = XCUIApplication()
        
        let testSecrets = TestSecretsStore().testSecrets
        
        app.buttons["emailSignInButton"].tap()

        let emailTextField = app.textFields["emailTextField"]
        emailTextField.tap()
        emailTextField.typeText(testSecrets.emailSignInUser.email)

        let passwordTextField = app.secureTextFields["passwordTextField"]
        passwordTextField.tap()
        passwordTextField.typeText(testSecrets.emailSignInUser.password)

        app.buttons["submitButton"].tap()
    }
    
    static func signOut() {
        let app = XCUIApplication()

        app.buttons["settingsButton"].tap()

        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Sign Out"]/*[[".cells.staticTexts[\"Sign Out\"]",".staticTexts[\"Sign Out\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    }
}
