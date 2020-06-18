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

class AppInfoStoreSpec: QuickSpec {
    override func spec() {
        var sut: AppInfoStore!
        
        beforeEach {
            sut = AppInfoStore(bundle: Bundle.main)
        }
        
        describe("appInfo") {
            describe("version") {
                it("is not empty") {
                    expect(sut.appInfo.version.isEmpty).to(beFalse())
                }
            }

            describe("build") {
                it("is not empty") {
                    expect(sut.appInfo.build.isEmpty).to(beFalse())
                }
            }

            describe("target") {
                it("is videoInternal") {
                    expect(sut.appInfo.target).to(equal(.videoInternal))
                }
            }
        }
    }
}
