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

class DeepLinkActivities {
    static func open(url: String, completion: () -> Void) {
        let contactsApp = XCUIApplication(bundleIdentifier: "com.apple.MobileAddressBook")

        XCTContext.runActivity(named: "Launch Contacts app") { _ in
            contactsApp.launch()

            XCTContext.runActivity(named: "Create new contact with URL") { _ in
                contactsApp.navigationBars["Contacts"].buttons["Add"].tap()

                let firstNameTextField = contactsApp.tables/*@START_MENU_TOKEN@*/.textFields["First name"]/*[[".cells.textFields[\"First name\"]",".textFields[\"First name\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
                firstNameTextField.tap()
                firstNameTextField.typeText(url)

                contactsApp.tables/*@START_MENU_TOKEN@*/.staticTexts["add url"]/*[[".cells[\"add url\"].staticTexts[\"add url\"]",".staticTexts[\"add url\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
                
                let homepageTextField = contactsApp.tables.textFields["homepage"]
                homepageTextField.tap()
                homepageTextField.typeText(url)
                
                contactsApp.navigationBars["New Contact"].buttons["Done"].tap()
            }

            contactsApp.tables.staticTexts[url].tap()
        }
        
        completion()

        XCTContext.runActivity(named: "Launch Contacts app") { _ in
            contactsApp.launch()

            XCTContext.runActivity(named: "Delete contact") { _ in
                contactsApp.navigationBars["CNContactView"].buttons["Edit"].tap()
                contactsApp.tables/*@START_MENU_TOKEN@*/.staticTexts["Delete Contact"]/*[[".cells.staticTexts[\"Delete Contact\"]",".staticTexts[\"Delete Contact\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
                contactsApp.sheets.scrollViews.otherElements.buttons["Delete Contact"].tap()
            }
        }
    }
}
