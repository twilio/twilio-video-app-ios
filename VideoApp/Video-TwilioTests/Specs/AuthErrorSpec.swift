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

class AuthErrorSpec: QuickSpec {
    override func spec() {
        describe("init") {
            context("when apiError is decodeError") {
                it("returns unknown") {
                    expect(AuthError(apiError: .decodeError)).to(equal(.unknown))
                }
            }

            context("when apiError is expiredPasscode") {
                it("returns expiredPasscode") {
                    expect(AuthError(apiError: .passcodeExpired)).to(equal(.passcodeExpired))
                }
            }

            context("when apiError is notConnectedToInternet") {
                it("returns networkError") {
                    expect(AuthError(apiError: .notConnectedToInternet)).to(equal(.networkError))
                }
            }

            context("when apiError is unauthorized") {
                it("returns wrongPasscode") {
                    expect(AuthError(apiError: .passcodeIncorrect)).to(equal(.passcodeIncorrect))
                }
            }
        }
    }
}
