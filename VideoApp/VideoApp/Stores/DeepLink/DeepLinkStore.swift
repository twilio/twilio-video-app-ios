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

protocol DeepLinkStoreWriting: AnyObject {
    var didReceiveDeepLink: (() -> Void)? { get set }
    func cache(deepLink: DeepLink)
    func consumeDeepLink() -> DeepLink?
}

class DeepLinkStore: DeepLinkStoreWriting {
    static let shared: DeepLinkStoreWriting = DeepLinkStore()
    var didReceiveDeepLink: (() -> Void)?
    var deepLink: DeepLink?

    func cache(deepLink: DeepLink) {
        self.deepLink = deepLink
        didReceiveDeepLink?()
    }
    
    func consumeDeepLink() -> DeepLink? {
        guard let deepLink = deepLink else { return nil }
        
        self.deepLink = nil
        return deepLink
    }
}
