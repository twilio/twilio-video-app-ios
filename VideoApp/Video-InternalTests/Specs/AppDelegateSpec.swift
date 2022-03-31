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
        var mockLaunchStoresFactory: MockLaunchStoresFactory!
        
        beforeEach {
            mockLaunchStoresFactory = MockLaunchStoresFactory()
            sut = AppDelegate()
            sut.launchStoresFactory = mockLaunchStoresFactory
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
    }
}
