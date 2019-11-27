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

class MockAuthStore: AuthStoreEverything {
    var invokedDelegateSetter = false
    var invokedDelegateSetterCount = 0
    var invokedDelegate: AuthStoreWritingDelegate?
    var invokedDelegateList = [AuthStoreWritingDelegate?]()
    var invokedDelegateGetter = false
    var invokedDelegateGetterCount = 0
    var stubbedDelegate: AuthStoreWritingDelegate!
    var delegate: AuthStoreWritingDelegate? {
        set {
            invokedDelegateSetter = true
            invokedDelegateSetterCount += 1
            invokedDelegate = newValue
            invokedDelegateList.append(newValue)
        }
        get {
            invokedDelegateGetter = true
            invokedDelegateGetterCount += 1
            return stubbedDelegate
        }
    }
    var invokedIsSignedInGetter = false
    var invokedIsSignedInGetterCount = 0
    var stubbedIsSignedIn: Bool! = false
    var isSignedIn: Bool {
        invokedIsSignedInGetter = true
        invokedIsSignedInGetterCount += 1
        return stubbedIsSignedIn
    }
    var invokedUserDisplayNameGetter = false
    var invokedUserDisplayNameGetterCount = 0
    var stubbedUserDisplayName: String! = ""
    var userDisplayName: String {
        invokedUserDisplayNameGetter = true
        invokedUserDisplayNameGetterCount += 1
        return stubbedUserDisplayName
    }
    var invokedStart = false
    var invokedStartCount = 0
    func start() {
        invokedStart = true
        invokedStartCount += 1
    }
    var invokedSignIn = false
    var invokedSignInCount = 0
    var invokedSignInParameters: (email: String, password: String)?
    var invokedSignInParametersList = [(email: String, password: String)]()
    var stubbedSignInCompletionResult: (Error?, Void)?
    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        invokedSignIn = true
        invokedSignInCount += 1
        invokedSignInParameters = (email, password)
        invokedSignInParametersList.append((email, password))
        if let result = stubbedSignInCompletionResult {
            completion(result.0)
        }
    }
    var invokedSignOut = false
    var invokedSignOutCount = 0
    func signOut() {
        invokedSignOut = true
        invokedSignOutCount += 1
    }
    var invokedOpenURL = false
    var invokedOpenURLCount = 0
    var invokedOpenURLParameters: (url: URL, sourceApplication: String?, annotation: Any?)?
    var invokedOpenURLParametersList = [(url: URL, sourceApplication: String?, annotation: Any?)]()
    var stubbedOpenURLResult: Bool! = false
    func openURL(_ url: URL, sourceApplication: String?, annotation: Any?) -> Bool {
        invokedOpenURL = true
        invokedOpenURLCount += 1
        invokedOpenURLParameters = (url, sourceApplication, annotation)
        invokedOpenURLParametersList.append((url, sourceApplication, annotation))
        return stubbedOpenURLResult
    }
    var invokedFetchTwilioAccessToken = false
    var invokedFetchTwilioAccessTokenCount = 0
    var invokedFetchTwilioAccessTokenParameters: (roomName: String, Void)?
    var invokedFetchTwilioAccessTokenParametersList = [(roomName: String, Void)]()
    var stubbedFetchTwilioAccessTokenCompletionResult: (String?, Error?)?
    func fetchTwilioAccessToken(roomName: String, completion: @escaping (String?, Error?) -> Void) {
        invokedFetchTwilioAccessToken = true
        invokedFetchTwilioAccessTokenCount += 1
        invokedFetchTwilioAccessTokenParameters = (roomName, ())
        invokedFetchTwilioAccessTokenParametersList.append((roomName, ()))
        if let result = stubbedFetchTwilioAccessTokenCompletionResult {
            completion(result.0, result.1)
        }
    }
}
