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

class MockTwilioVideoAppAPI: TwilioVideoAppAPIProtocol {
    var invokedRetrieveAccessToken = false
    var invokedRetrieveAccessTokenCount = 0
    var invokedRetrieveAccessTokenParameters: (identity: String, roomName: String, authToken: String, environment: TwilioVideoAppAPIEnvironment, topology: TwilioVideoAppAPITopology)?
    var invokedRetrieveAccessTokenParametersList = [(identity: String, roomName: String, authToken: String, environment: TwilioVideoAppAPIEnvironment, topology: TwilioVideoAppAPITopology)]()
    var stubbedRetrieveAccessTokenCompletionBlockResult: (String?, Error?)?
    func retrieveAccessToken(
    forIdentity identity: String,
    roomName: String,
    authToken: String,
    environment: TwilioVideoAppAPIEnvironment,
    topology: TwilioVideoAppAPITopology,
    completionBlock: @escaping (String?, Error?) -> Void
    ) {
        invokedRetrieveAccessToken = true
        invokedRetrieveAccessTokenCount += 1
        invokedRetrieveAccessTokenParameters = (identity, roomName, authToken, environment, topology)
        invokedRetrieveAccessTokenParametersList.append((identity, roomName, authToken, environment, topology))
        if let result = stubbedRetrieveAccessTokenCompletionBlockResult {
            completionBlock(result.0, result.1)
        }
    }
}
