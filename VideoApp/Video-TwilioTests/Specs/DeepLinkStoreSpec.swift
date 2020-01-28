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

class DeepLinkStoreSpec: QuickSpec {
    override func spec() {
        var sut: DeepLinkStore!
        
        beforeEach {
            sut = DeepLinkStore()
        }
        
        describe("cache") {
            context("when deepLink is foo") {
                it("sets deepLink to foo") {
                    sut.cache(deepLink: .room(roomName: "foo"))
                    
                    expect(sut.deepLink).to(equal(.room(roomName: "foo")))
                }
            }

            context("when deepLink is bar") {
                it("sets deepLink to bar") {
                    sut.cache(deepLink: .room(roomName: "bar"))
                    
                    expect(sut.deepLink).to(equal(.room(roomName: "bar")))
                }
            }
            
            it("calls didReceiveDeepLink") {
                var invokedDidReceiveDeepLinkCount = 0
                sut.didReceiveDeepLink = { invokedDidReceiveDeepLinkCount += 1 }
                
                sut.cache(deepLink: .room(roomName: ""))
                
                expect(invokedDidReceiveDeepLinkCount).to(equal(1))
            }
        }
        
        describe("consumeDeepLink") {
            context("when deepLink is nil") {
                it("returns nil") {
                    sut.deepLink = nil
                    
                    expect(sut.consumeDeepLink()).to(beNil())
                }
            }
            
            context("when deepLink is foo") {
                beforeEach {
                    sut.deepLink = .room(roomName: "foo")
                }
                
                it("sets deepLink to nil") {
                    _ = sut.consumeDeepLink()
                    
                    expect(sut.deepLink).to(beNil())
                }
                
                it("returns foo") {
                    expect(sut.consumeDeepLink()).to(equal(.room(roomName: "foo")))
                }
            }
        }
    }
}
