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

@testable import VideoApp

class MockUserActivityStore: UserActivityStoreWriting {
    var invokedContinueUserActivity = false
    var invokedContinueUserActivityCount = 0
    var invokedContinueUserActivityParameters: (userActivity: NSUserActivity, Void)?
    var invokedContinueUserActivityParametersList = [(userActivity: NSUserActivity, Void)]()
    var stubbedContinueUserActivityResult: Bool! = false
    func continueUserActivity(_ userActivity: NSUserActivity) -> Bool {
        invokedContinueUserActivity = true
        invokedContinueUserActivityCount += 1
        invokedContinueUserActivityParameters = (userActivity, ())
        invokedContinueUserActivityParametersList.append((userActivity, ()))
        return stubbedContinueUserActivityResult
    }
}
