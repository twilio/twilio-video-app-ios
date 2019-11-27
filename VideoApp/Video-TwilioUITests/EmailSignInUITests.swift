//
//  Copyright (C) 2019 Twilio, Inc.
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

class EmailSignInUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    func testSignIn() {
        let app = XCUIApplication()
        app.launch()

        app.buttons["emailSignInButton"].tap()
        
        let emailTextField = app.textFields["emailTextField"]
        emailTextField.tap()
        emailTextField.typeText("trozum+uitest@twilio.com")
        
        let passwordTextField = app.secureTextFields["passwordTextField"]
        passwordTextField.tap()
        passwordTextField.typeText("password")
        
        app.buttons["signInButton"].tap()

        let settingsButton = app.buttons["settingsButton"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: settingsButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssert(app.staticTexts["userNameLabel"].label == "trozum+uitest@twilio.com")
        
        settingsButton.tap()
        
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Sign Out"]/*[[".cells.staticTexts[\"Sign Out\"]",".staticTexts[\"Sign Out\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    }
}
