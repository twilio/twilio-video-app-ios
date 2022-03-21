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

class AppSettingsStoreSpec: QuickSpec {
    override func spec() {
        var mockNotificationCenter: MockNotificationCenter!
        var mockDispatchQueue: MockDispatchQueue!
        var mockUserDefaults: MockUserDefaults!
        var mockAppInfoStore: MockAppInfoStore!
        
        beforeEach {
            mockAppInfoStore = MockAppInfoStore()
            AppSettingsStore.appInfoStore = mockAppInfoStore
            mockNotificationCenter = MockNotificationCenter()
            mockDispatchQueue = MockDispatchQueue()
            mockUserDefaults = MockUserDefaults()
        }
        
        func makeSUT() -> AppSettingsStore {
            AppSettingsStore(
                notificationCenter: mockNotificationCenter,
                queue: mockDispatchQueue,
                userDefaults: mockUserDefaults
            )
        }
        
        describe("videoCodec") {
            context("when target is videoInternal") {
                it("is defaulted to vp8SimulcastVGA") {
                    mockAppInfoStore.stubbedAppInfo = .stub(target: .videoInternal)
                    
                    expect(makeSUT().videoCodec).to(equal(.auto))
                }
            }
            
            context("when target is videoCommunity") {
                it("is defaulted to vp8") {
                    mockAppInfoStore.stubbedAppInfo = .stub(target: .videoCommunity)
                    
                    expect(makeSUT().videoCodec).to(equal(.vp8))
                }
            }
        }
    }
}
