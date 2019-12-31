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
        
        fdescribe("didFinishLaunchingWithOptions") {
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
            describe("openURL") {
                it("is called once") {
                    
                }
                
                context("when url is foo") {
                    
                }
                
                context("when url is bar") {
                    
                }
                
                context("when sourceApplication is foo") {
                    
                }
                
                context("when sourceApplication is bar") {
                    
                }
                
                context("when annotation")
            }
        }
    }
}






class MockLaunchFlow: LaunchFlow {
    var invokedStart = false
    var invokedStartCount = 0
    func start() {
        invokedStart = true
        invokedStartCount += 1
    }
}

class MockLaunchFlowFactory: LaunchFlowFactory {
    var invokedMakeLaunchFlow = false
    var invokedMakeLaunchFlowCount = 0
    var invokedMakeLaunchFlowParameters: (window: UIWindow, Void)?
    var invokedMakeLaunchFlowParametersList = [(window: UIWindow, Void)]()
    var stubbedMakeLaunchFlowResult: LaunchFlow!
    func makeLaunchFlow(window: UIWindow) -> LaunchFlow {
        invokedMakeLaunchFlow = true
        invokedMakeLaunchFlowCount += 1
        invokedMakeLaunchFlowParameters = (window, ())
        invokedMakeLaunchFlowParametersList.append((window, ()))
        return stubbedMakeLaunchFlowResult
    }
}

class MockLaunchStore: LaunchStore {
    var invokedStart = false
    var invokedStartCount = 0
    func start() {
        invokedStart = true
        invokedStartCount += 1
    }
}

class MockLaunchStoresFactory: LaunchStoresFactory {
    var invokedMakeLaunchStores = false
    var invokedMakeLaunchStoresCount = 0
    var stubbedMakeLaunchStoresResult: [LaunchStore]! = []
    func makeLaunchStores() -> [LaunchStore] {
        invokedMakeLaunchStores = true
        invokedMakeLaunchStoresCount += 1
        return stubbedMakeLaunchStoresResult
    }
}

class MockURLOpener: URLOpening {
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
}

class MockURLOpenerFactory: URLOpenerFactory {
    var invokedMakeURLOpener = false
    var invokedMakeURLOpenerCount = 0
    var stubbedMakeURLOpenerResult: URLOpening!
    func makeURLOpener() -> URLOpening {
        invokedMakeURLOpener = true
        invokedMakeURLOpenerCount += 1
        return stubbedMakeURLOpenerResult
    }
}
