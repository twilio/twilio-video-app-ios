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

class DeepLinkSpec: QuickSpec {
    override func spec() {
        describe("init") {
            context("when path is /room/foo") {
                it("returns room with foo roomName") {
                    expect(DeepLink(url: URL(string: "https://www.twilio.com/room/foo")!)).to(equal(DeepLink.room(roomName: "foo")))
                }
            }

            context("when path is /room/bar") {
                it("returns room with bar roomName") {
                    expect(DeepLink(url: URL(string: "https://www.twilio.com/room/bar")!)).to(equal(DeepLink.room(roomName: "bar")))
                }
            }

            context("when path is /") {
                it("returns nil") {
                    expect(DeepLink(url: URL(string: "https://www.twilio.com")!)).to(beNil())
                }
            }
        }
    }
}
