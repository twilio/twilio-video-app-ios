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

import Nimble
import Quick

@testable import VideoApp

class AppDelegateSpec: QuickSpec {
    override func spec() {
        var sut: AppDelegate!
        var mockLaunchFlowFactory: MockLaunchFlowFactory!
        var mockLaunchStoresFactory: MockLaunchStoresFactory!
        var mockURLOpenerFactory: MockURLOpenerFactory!
        
        beforeEach {
            mockLaunchFlowFactory = MockLaunchFlowFactory()
            mockLaunchStoresFactory = MockLaunchStoresFactory()
            mockURLOpenerFactory = MockURLOpenerFactory()
            sut = AppDelegate()
            sut.launchFlowFactory = mockLaunchFlowFactory
            sut.launchStoresFactory = mockLaunchStoresFactory
            sut.urlOpenerFactory = mockURLOpenerFactory
        }
        
        describe("didFinishLaunchingWithOptions") {
            it("calls start on all launch stores") {
                let mockFooLaunchStore = MockLaunchStore()
                let mockBarLaunchStore = MockLaunchStore()
                mockLaunchStoresFactory.stubbedMakeLaunchStoresResult = [mockFooLaunchStore, mockBarLaunchStore]
                
                _ = sut.application(.shared, didFinishLaunchingWithOptions: nil)
                
                expect(mockLaunchStoresFactory.invokedMakeLaunchStoresCount).to(equal(1))
                expect(mockFooLaunchStore.invokedStartCount).to(equal(1))
                expect(mockBarLaunchStore.invokedStartCount).to(equal(1))
            }
            
            it("returns true") {
                mockLaunchStoresFactory.stubbedMakeLaunchStoresResult = []
                
                expect(sut.application(.shared, didFinishLaunchingWithOptions: nil)).to(beTrue())
            }
        }
        
        describe("openURL") {
            var mockURLOpener: MockURLOpener!
            
            beforeEach {
                mockURLOpener = MockURLOpener()
                mockURLOpenerFactory.stubbedMakeURLOpenerResult = mockURLOpener
            }
            
            @discardableResult func openURL(url: String = "www.foo.com") -> Bool {
                return sut.application(.shared, open: URL(string: url)!)
            }

            describe("openURL") {
                it("is called once") {
                    openURL()
                    
                    expect(mockURLOpener.invokedOpenURLCount).to(equal(1))
                }
                
                context("when url is foo") {
                    it("is called with foo url") {
                        openURL(url: "www.foo.com")

                        expect(mockURLOpener.invokedOpenURLParameters?.url).to(equal(URL(string: "www.foo.com")!))
                    }
                }

                context("when url is bar") {
                    it("is called with bar url") {
                        openURL(url: "www.bar.com")

                        expect(mockURLOpener.invokedOpenURLParameters?.url).to(equal(URL(string: "www.bar.com")!))
                    }
                }
                
                context("when it returns true") {
                    it("returns true") {
                        mockURLOpener.stubbedOpenURLResult = true
                        
                        expect(openURL()).to(beTrue())
                    }
                }
                
                context("when it returns false") {
                    it("returns false") {
                        mockURLOpener.stubbedOpenURLResult = false
                        
                        expect(openURL()).to(beFalse())
                    }
                }
            }
        }
    }
}
