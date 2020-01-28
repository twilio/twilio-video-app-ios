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
        var mockUserActivityStoreFactory: MockUserActivityStoreFactory!
        
        beforeEach {
            mockLaunchFlowFactory = MockLaunchFlowFactory()
            mockLaunchStoresFactory = MockLaunchStoresFactory()
            mockURLOpenerFactory = MockURLOpenerFactory()
            mockUserActivityStoreFactory = MockUserActivityStoreFactory()
            sut = AppDelegate()
            sut.launchFlowFactory = mockLaunchFlowFactory
            sut.launchStoresFactory = mockLaunchStoresFactory
            sut.urlOpenerFactory = mockURLOpenerFactory
            sut.userActivityStoreFactory = mockUserActivityStoreFactory
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
        
        describe("continueUserActivity") {
            var mockUserActivityStore: MockUserActivityStore!
            
            beforeEach {
                mockUserActivityStore = MockUserActivityStore()
                mockUserActivityStoreFactory.stubbedMakeUserActivityStoreResult = mockUserActivityStore
            }
            
            @discardableResult func continueUserActivity(url: String = "https://www.foo.com") -> Bool {
                let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
                userActivity.webpageURL = URL(string: url)!
                return sut.application(.shared, continue: userActivity) { _ in }
            }
            
            context("when userActivity is foo") {
                it("calls continueUserActivity with foo userActivity") {
                    continueUserActivity(url: "https://www.foo.com")
                    
                    expect(mockUserActivityStore.invokedContinueUserActivityParameters?.userActivity.webpageURL?.absoluteString).to(equal("https://www.foo.com"))
                }
            }
            
            context("when userActivity is bar") {
                it("calls continueUserActivity with bar userActivity") {
                    continueUserActivity(url: "https://www.bar.com")
                    
                    expect(mockUserActivityStore.invokedContinueUserActivityParameters?.userActivity.webpageURL?.absoluteString).to(equal("https://www.bar.com"))
                }
            }
            
            context("when continueUserActivity returns true") {
                it("returns true") {
                    mockUserActivityStore.stubbedContinueUserActivityResult = true
                    
                    expect(continueUserActivity()).to(beTrue())
                }
            }
            
            context("when continueUserActivity returns false") {
                it("returns false") {
                    mockUserActivityStore.stubbedContinueUserActivityResult = false
                    
                    expect(continueUserActivity()).to(beFalse())
                }
            }
        }
    }
}
