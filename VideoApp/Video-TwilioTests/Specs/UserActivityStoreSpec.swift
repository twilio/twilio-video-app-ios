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

import Nimble
import Quick

@testable import VideoApp

class UserActivityStoreSpec: QuickSpec {
    override func spec() {
        var sut: UserActivityStore!
        var mockDeepLinkStore: MockDeepLinkStore!
        
        beforeEach {
            mockDeepLinkStore = MockDeepLinkStore()
            sut = UserActivityStore(deepLinkStore: mockDeepLinkStore)
        }
        
        describe("continueUserActivity") {
            @discardableResult func continueUserActivity(url: String?) -> Bool {
                let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
                
                if let url = url {
                    userActivity.webpageURL = URL(string: url)!
                }
                
                return sut.continueUserActivity(userActivity)
            }

            context("when url is foo") {
                it("calls cache with foo deepLink") {
                    continueUserActivity(url: "https://twilio-video-react.appspot.com/room/foo")

                    expect(mockDeepLinkStore.invokedCacheCount).to(equal(1))
                    expect(mockDeepLinkStore.invokedCacheParameters?.deepLink).to(equal(.room(roomName: "foo")))
                }
                
                it("returns true") {
                    expect(continueUserActivity(url: "https://twilio-video-react.appspot.com/room/foo")).to(beTrue())
                }
            }
            
            context("when url is nil") {
                it("does not call cache") {
                    continueUserActivity(url: nil)

                    expect(mockDeepLinkStore.invokedCacheCount).to(equal(0))
                }
                
                it("returns false") {
                    expect(continueUserActivity(url: nil)).to(beFalse())
                }
            }
        }
    }
}
