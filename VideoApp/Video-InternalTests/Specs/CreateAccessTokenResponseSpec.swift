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

class CreateTwilioAccessTokenResponseSpec: QuickSpec {
    override func spec() {
        describe("init") {
            context("when room_type does not match any case") {
                it("is set to unknown") {
                    let json = try! JSONEncoder().encode(["token": "", "room_type": ""])
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    expect(try! decoder.decode(CreateTwilioAccessTokenResponse.self, from: json).roomType).to(equal(.unknown))
                }
            }
        }
    }
}
