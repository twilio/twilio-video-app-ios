//
//  MockTwilioVideoAppAPI.swift
//  Video-TwilioTests
//
//  Created by Tim Rozum on 10/16/19.
//  Copyright © 2019 Twilio, Inc. All rights reserved.
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
