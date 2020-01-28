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

class MockDeepLinkStore: DeepLinkStoreWriting {
    var invokedDidReceiveDeepLinkSetter = false
    var invokedDidReceiveDeepLinkSetterCount = 0
    var invokedDidReceiveDeepLink: (() -> Void)?
    var invokedDidReceiveDeepLinkList = [(() -> Void)?]()
    var invokedDidReceiveDeepLinkGetter = false
    var invokedDidReceiveDeepLinkGetterCount = 0
    var stubbedDidReceiveDeepLink: (() -> Void)!
    var didReceiveDeepLink: (() -> Void)? {
        set {
            invokedDidReceiveDeepLinkSetter = true
            invokedDidReceiveDeepLinkSetterCount += 1
            invokedDidReceiveDeepLink = newValue
            invokedDidReceiveDeepLinkList.append(newValue)
        }
        get {
            invokedDidReceiveDeepLinkGetter = true
            invokedDidReceiveDeepLinkGetterCount += 1
            return stubbedDidReceiveDeepLink
        }
    }
    var invokedCache = false
    var invokedCacheCount = 0
    var invokedCacheParameters: (deepLink: DeepLink, Void)?
    var invokedCacheParametersList = [(deepLink: DeepLink, Void)]()
    func cache(deepLink: DeepLink) {
        invokedCache = true
        invokedCacheCount += 1
        invokedCacheParameters = (deepLink, ())
        invokedCacheParametersList.append((deepLink, ()))
    }
    var invokedConsumeDeepLink = false
    var invokedConsumeDeepLinkCount = 0
    var stubbedConsumeDeepLinkResult: DeepLink!
    func consumeDeepLink() -> DeepLink? {
        invokedConsumeDeepLink = true
        invokedConsumeDeepLinkCount += 1
        return stubbedConsumeDeepLinkResult
    }
}
