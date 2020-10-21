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
        var sut: PasscodeComponents?
        
        describe("init") {
            context("when string is new format") {
                context("when string length is 14") {
                    beforeEach {
                        sut = try? PasscodeComponents(string: "65897412385467")
                    }
                    
                    it("sets passcode to entire string") {
                        expect(sut?.passcode).to(equal("65897412385467"))
                    }

                    it("sets appID to characters at indices 6 to 9") {
                        expect(sut?.appID).to(equal("1238"))
                    }
                    
                    it("sets serverlessID to last 4 characters") {
                        expect(sut?.serverlessID).to(equal("5467"))
                    }
                }
                
                context("when string length is 20") {
                    beforeEach {
                        sut = try? PasscodeComponents(string: "59846823174859632894")
                    }
                    
                    it("sets passcode to entire string") {
                        expect(sut?.passcode).to(equal("59846823174859632894"))
                    }

                    it("sets appID to characters at indices 6 to 9") {
                        expect(sut?.appID).to(equal("2317"))
                    }
                    
                    it("sets serverlessID to last 10 characters") {
                        expect(sut?.serverlessID).to(equal("4859632894"))
                    }
                }
            }
            
            context("when string is old format") {
                context("when string length is 10") {
                    beforeEach {
                        sut = try? PasscodeComponents(string: "5987462314")
                    }
                    
                    it("sets passcode to entire string") {
                        expect(sut?.passcode).to(equal("5987462314"))
                    }

                    it("sets appID to nil") {
                        expect(sut?.appID).to(beNil())
                    }
                    
                    it("sets serverlessID to last 4 characters") {
                        expect(sut?.serverlessID).to(equal("2314"))
                    }
                }
                
                context("when string length is 13") {
                    beforeEach {
                        sut = try? PasscodeComponents(string: "9874652871365")
                    }
                    
                    it("sets passcode to entire string") {
                        expect(sut?.passcode).to(equal("9874652871365"))
                    }

                    it("sets appID to nil") {
                        expect(sut?.appID).to(beNil())
                    }

                    it("sets serverlessID to last 7 characters") {
                        expect(sut?.serverlessID).to(equal("2871365"))
                    }
                }

            }
            
            context("when string is invalid") {
                context("when string length is 6") {
                    it("throws passcodeIncorrect error") {
                        expect({ try PasscodeComponents(string: "256984") }).to(throwError(AuthError.passcodeIncorrect))
                    }
                }
            }
        }
    }
}
