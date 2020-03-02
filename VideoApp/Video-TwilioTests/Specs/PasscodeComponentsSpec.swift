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

class PasscodeComponentsSpec: QuickSpec {
    override func spec() {
        var sut: PasscodeComponents!
        
        describe("init") {
            context("when string is 10 characters") {
                beforeEach {
                    sut = PasscodeComponents(string: "2546985627")
                }
                
                it("sets passcode to entire string") {
                    expect(sut.passcode).to(equal("2546985627"))
                }
                
                it("sets appID to last 4 characters") {
                    expect(sut.appID).to(equal("5627"))
                }
            }
            
            context("when string is 11 characters") {
                beforeEach {
                    sut = PasscodeComponents(string: "65874258516")
                }
                
                it("sets passcode to entire string") {
                    expect(sut.passcode).to(equal("65874258516"))
                }
                
                it("sets appID to last 5 characters") {
                    expect(sut.appID).to(equal("58516"))
                }
            }
        }
    }
}
