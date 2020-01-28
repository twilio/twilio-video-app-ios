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

protocol UserActivityStoreWriting: AnyObject {
    @discardableResult func continueUserActivity(_ userActivity: NSUserActivity) -> Bool
}

class UserActivityStore: UserActivityStoreWriting {
    private let deepLinkStore: DeepLinkStoreWriting
    
    init(deepLinkStore: DeepLinkStoreWriting) {
        self.deepLinkStore = deepLinkStore
    }
    
    @discardableResult func continueUserActivity(_ userActivity: NSUserActivity) -> Bool {
        guard let url = userActivity.webpageURL, let deepLink = DeepLink(url: url) else { return false }
        
        deepLinkStore.cache(deepLink: deepLink)
        return true
    }
}
