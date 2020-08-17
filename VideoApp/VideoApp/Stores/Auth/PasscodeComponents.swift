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

import Foundation

struct PasscodeComponents {
    let passcode: String
    let appID: String?
    let serverlessID: String
    
    init(string: String) throws {
        passcode = string
        let shortPasscodeLength = 6
        let appIDLength = 4
        let serverlessIDMinLength = 4
        let newFormatMinLength = shortPasscodeLength + appIDLength + serverlessIDMinLength
        let oldFormatMinLength = shortPasscodeLength + serverlessIDMinLength

        if string.count >= newFormatMinLength {
            let appIDStartIndex = string.index(string.startIndex, offsetBy: shortPasscodeLength)
            let appIDEndIndex = string.index(appIDStartIndex, offsetBy: appIDLength - 1)
            appID = String(string[appIDStartIndex...appIDEndIndex])
            let serverlessIDStartIndex = string.index(after: appIDEndIndex)
            serverlessID = String(string[serverlessIDStartIndex...])
        } else if string.count >= oldFormatMinLength {
            appID = nil
            let serverlessIDStartIndex = string.index(string.startIndex, offsetBy: shortPasscodeLength)
            serverlessID = String(string[serverlessIDStartIndex...])
        } else {
            throw AuthError.passcodeIncorrect
        }
    }
}
