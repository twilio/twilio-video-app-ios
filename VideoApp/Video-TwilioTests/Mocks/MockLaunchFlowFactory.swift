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

@testable import VideoApp

class MockLaunchFlowFactory: LaunchFlowFactory {
    var invokedMakeLaunchFlow = false
    var invokedMakeLaunchFlowCount = 0
    var invokedMakeLaunchFlowParameters: (window: UIWindow, Void)?
    var invokedMakeLaunchFlowParametersList = [(window: UIWindow, Void)]()
    var stubbedMakeLaunchFlowResult: LaunchFlow!
    func makeLaunchFlow(window: UIWindow) -> LaunchFlow {
        invokedMakeLaunchFlow = true
        invokedMakeLaunchFlowCount += 1
        invokedMakeLaunchFlowParameters = (window, ())
        invokedMakeLaunchFlowParametersList.append((window, ()))
        return stubbedMakeLaunchFlowResult
    }
}
