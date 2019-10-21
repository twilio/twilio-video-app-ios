//
//  MockFirebaseAuthManager.swift
//  Video-TwilioTests
//
//  Created by Tim Rozum on 10/16/19.
//  Copyright © 2019 Twilio, Inc. All rights reserved.
//

@testable import VideoApp

class MockFirebaseAuthManager: FirebaseAuthManagerProtocol {
    var invokedCurrentUserDisplayNameGetter = false
    var invokedCurrentUserDisplayNameGetterCount = 0
    var stubbedCurrentUserDisplayName: String! = ""
    var currentUserDisplayName: String {
        invokedCurrentUserDisplayNameGetter = true
        invokedCurrentUserDisplayNameGetterCount += 1
        return stubbedCurrentUserDisplayName
    }
    var invokedGetIDToken = false
    var invokedGetIDTokenCount = 0
    var stubbedGetIDTokenCompletionResult: (String?, Error?)?
    func getIDToken(completion: @escaping (String?, Error?) -> Void) {
        invokedGetIDToken = true
        invokedGetIDTokenCount += 1
        if let result = stubbedGetIDTokenCompletionResult {
            completion(result.0, result.1)
        }
    }
}
