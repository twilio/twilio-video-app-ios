//
//  Copyright (C) 2022 Twilio, Inc.
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

class GridLayoutViewModelSpec: QuickSpec {
    override func spec() {
        var sut: GridLayoutViewModel!
        
        beforeEach {
            sut = GridLayoutViewModel()
        }
        
        describe("addParticipant") {
            context("when there are no pages") {
                it("adds the participant to a new page") {
                    sut.addParticipant(.stub(identity: "foo"))
                    
                    expect(sut.pages.count).to(equal(1))
                    expect(sut.pages[0].participants.count).to(equal(1))
                    expect(sut.pages[0].participants[0].identity).to(equal("foo"))
                }
            }
            
            context("when the last page is full") {
                it("adds the participant to a new page") {
                    Array(1...sut.maxParticipantsPerPage + 1)
                        .forEach { sut.addParticipant(.stub(identity: "Participant \($0)")) }

                    expect(sut.pages.count).to(equal(2))
                    expect(sut.pages[0].participants.count).to(equal(6))
                    expect(sut.pages[1].participants.count).to(equal(1))
                    expect(sut.pages[1].participants[0].identity).to(equal("Participant 7"))
                }
            }
            
            context("when the last page is not full") {
                it("adds the participant to the end of the last page") {
                    sut.addParticipant(.stub(identity: "foo"))
                    
                    sut.addParticipant(.stub(identity: "bar"))
                    
                    expect(sut.pages.count).to(equal(1))
                    expect(sut.pages[0].participants.count).to(equal(2))
                    expect(sut.pages[0].participants[1].identity).to(equal("bar"))

                }
            }
        }
        
        describe("removeParticipant") {
            context("when the participant is on the first page and there are 2 pages") {
                it("replaces the user with the first participant from the second page") {
                    Array(1...12).forEach { sut.addParticipant(.stub(identity: String($0))) }

                    sut.removeParticipant(identity: "3")
                    
                    expect(sut.pages[0].participants.map { $0.identity }).to(equal(["1", "2", "7", "4", "5", "6"]))
                    expect(sut.pages[1].participants.map { $0.identity }).to(equal(["8", "9", "10", "11", "12"]))
                }
            }
            
            context("when the participant is on the second page and there are 3 pages") {
                it("removes the user and shifts newer participants forward") {
                    Array(1...18).forEach { sut.addParticipant(.stub(identity: String($0))) }

                    sut.removeParticipant(identity: "7")
                    
                    expect(sut.pages[1].participants.map { $0.identity }).to(equal(Array(8...13).map { String($0) }))
                    expect(sut.pages[2].participants.map { $0.identity }).to(equal(Array(14...18).map { String($0) }))
                }
            }
            
            context("when there is 1 participant on the last page") {
                it("removes the last page") {
                    sut.pages = [GridLayoutViewModel.Page(identifier: 0, participants: [.stub(identity: "foo")])]
                    
                    sut.removeParticipant(identity: "foo")
                    
                    expect(sut.pages.isEmpty).to(beTrue())
                }
            }
            
            context("when the participant is not found") {
                it("does nothing") {
                    sut.removeParticipant(identity: "foo")
                    
                    expect(sut.pages.isEmpty).to(beTrue())
                }
            }
        }
        
        describe("updateParticipant") {
            context("when a participant on the third page becomes dominant speaker") {
                beforeEach {
                    Array(1...18).forEach { sut.addParticipant(.stub(identity: String($0), dominantSpeakerStartTime: Date())) }
                    sut.pages[0].participants[2].dominantSpeakerStartTime = .distantPast

                    sut.updateParticipant(.stub(identity: "15", isDominantSpeaker: true, dominantSpeakerStartTime: Date()))
                }
                
                it("is moved to the position of the oldest dominant speaker on the first page") {
                    expect(sut.pages[0].participants.map { $0.identity }).to(equal(["1", "2", "15", "4", "5", "6"]))
                }
                
                it("moves the oldest dominant speaker on the first page to the start of the second page") {
                    expect(sut.pages[1].participants.map { $0.identity }).to(equal(["3", "7", "8", "9", "10", "11"]))
                }
                
                it("moves the last participant on the second page to the start of the third page") {
                    expect(sut.pages[2].participants.map { $0.identity }).to(equal(["12", "13", "14", "16", "17", "18"]))
                }
            }
            
            // inserParticipant create new page
            context("when the second page only has 1 participant and they become dominant spekaer") {
                beforeEach {
                    Array(1...7).forEach { sut.addParticipant(.stub(identity: String($0), dominantSpeakerStartTime: Date())) }
                    sut.pages[0].participants[2].dominantSpeakerStartTime = .distantPast

                    sut.updateParticipant(.stub(identity: "7", isDominantSpeaker: true, dominantSpeakerStartTime: Date()))
                }

                it("is moved to the position of the oldest dominant speaker on the first page") {
                    expect(sut.pages[0].participants.map { $0.identity }).to(equal(["1", "2", "7", "4", "5", "6"]))
                }

                it("moves the oldest dominant speaker on the first page to the second page") {
                    expect(sut.pages[1].participants.map { $0.identity }).to(equal(["3"]))
                }
            }
            
            // shiftRight new page
            context("when the third page only has 1 participant and they become dominant speaker") {
                beforeEach {
                    Array(1...13).forEach { sut.addParticipant(.stub(identity: String($0), dominantSpeakerStartTime: Date())) }
                    sut.pages[0].participants[2].dominantSpeakerStartTime = .distantPast

                    sut.updateParticipant(.stub(identity: "13", isDominantSpeaker: true, dominantSpeakerStartTime: Date()))
                }

                it("is moved to the position of the oldest dominant speaker on the first page") {
                    expect(sut.pages[0].participants.map { $0.identity }).to(equal(["1", "2", "13", "4", "5", "6"]))
                }

                it("moves the oldest dominant speaker on the first page to the second page") {
                    expect(sut.pages[1].participants.map { $0.identity }).to(equal(["3", "7", "8", "9", "10", "11"]))
                }

                it("shifts the last participant from page 2 to page 3") {
                    expect(sut.pages[2].participants.map { $0.identity }).to(equal(["12"]))
                }
            }

            context("when the participant is not found") {
                it("does nothing") {
                    sut.updateParticipant(.stub(identity: "foo"))
                    
                    expect(sut.pages.isEmpty).to(beTrue())
                }
            }
            
            context("when the participant is on the first page") {
                it("updates the participant in place") {
                    sut.addParticipant(.stub(identity: "foo", isMuted: false))
                    
                    sut.updateParticipant(.stub(identity: "foo", isMuted: true))
                    
                    expect(sut.pages[0].participants[0].isMuted).to(beTrue())
                }
            }
        }
    }
}
