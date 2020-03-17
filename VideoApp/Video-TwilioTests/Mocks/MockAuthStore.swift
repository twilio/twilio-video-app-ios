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

class MockAuthStore: AuthStoreWriting {
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
    var invokedPasscodeGetter = false
    var invokedPasscodeGetterCount = 0
    var stubbedPasscode: String!
    var passcode: String? {
        invokedPasscodeGetter = true
        invokedPasscodeGetterCount += 1
        return stubbedPasscode
    }
    var invokedUserDisplayNameGetter = false
    var invokedUserDisplayNameGetterCount = 0
    var stubbedUserDisplayName: String! = ""
    var userDisplayName: String {
        invokedUserDisplayNameGetter = true
        invokedUserDisplayNameGetterCount += 1
        return stubbedUserDisplayName
    }
    var invokedRefreshIDToken = false
    var invokedRefreshIDTokenCount = 0
    var shouldInvokeRefreshIDTokenCompletion = false
    func refreshIDToken(completion: @escaping () -> Void) {
        invokedRefreshIDToken = true
        invokedRefreshIDTokenCount += 1
        if shouldInvokeRefreshIDTokenCompletion {
            completion()
        }
    }
    var invokedSignInEmail = false
    var invokedSignInEmailCount = 0
    var invokedSignInEmailParameters: (email: String, password: String)?
    var invokedSignInEmailParametersList = [(email: String, password: String)]()
    var stubbedSignInEmailCompletionResult: (AuthError?, Void)?
    func signIn(email: String, password: String, completion: @escaping (AuthError?) -> Void) {
        invokedSignInEmail = true
        invokedSignInEmailCount += 1
        invokedSignInEmailParameters = (email, password)
        invokedSignInEmailParametersList.append((email, password))
        if let result = stubbedSignInEmailCompletionResult {
            completion(result.0)
        }
    }
    var invokedSignInUserIdentity = false
    var invokedSignInUserIdentityCount = 0
    var invokedSignInUserIdentityParameters: (userIdentity: String, passcode: String)?
    var invokedSignInUserIdentityParametersList = [(userIdentity: String, passcode: String)]()
    var stubbedSignInUserIdentityCompletionResult: (AuthError?, Void)?
    func signIn(userIdentity: String, passcode: String, completion: @escaping (AuthError?) -> Void) {
        invokedSignInUserIdentity = true
        invokedSignInUserIdentityCount += 1
        invokedSignInUserIdentityParameters = (userIdentity, passcode)
        invokedSignInUserIdentityParametersList.append((userIdentity, passcode))
        if let result = stubbedSignInUserIdentityCompletionResult {
            completion(result.0)
        }
    }
    var invokedSignOut = false
    var invokedSignOutCount = 0
    func signOut() {
        invokedSignOut = true
        invokedSignOutCount += 1
    }
    var invokedStart = false
    var invokedStartCount = 0
    func start() {
        invokedStart = true
        invokedStartCount += 1
    }
    var invokedOpenURL = false
    var invokedOpenURLCount = 0
    var invokedOpenURLParameters: (url: URL, Void)?
    var invokedOpenURLParametersList = [(url: URL, Void)]()
    var stubbedOpenURLResult: Bool! = false
    func openURL(_ url: URL) -> Bool {
        invokedOpenURL = true
        invokedOpenURLCount += 1
        invokedOpenURLParameters = (url, ())
        invokedOpenURLParametersList.append((url, ()))
        return stubbedOpenURLResult
    }
}
