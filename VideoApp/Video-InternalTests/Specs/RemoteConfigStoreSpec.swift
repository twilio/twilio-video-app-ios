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

class RemoteConfigStoreSpec: QuickSpec {
    override func spec() {
        var sut: RemoteConfigStore!
        var mockAppSettingsStore: MockAppSettingsStore!
        var mockAppInfoStore: MockAppInfoStore!
        
        beforeEach {
            mockAppSettingsStore = MockAppSettingsStore()
            mockAppInfoStore = MockAppInfoStore()
            sut = RemoteConfigStore(appSettingsStore: mockAppSettingsStore, appInfoStore: mockAppInfoStore)
        }
        
        describe("roomType") {
            describe("get") {
                context("when remoteRoomType setting is peerToPeer") {
                    it("returns peerToPeer") {
                        mockAppSettingsStore.stubbedRemoteRoomType = .peerToPeer
                        
                        expect(sut.roomType).to(equal(.peerToPeer))
                    }
                }
                
                context("when remoteRoomType setting is group") {
                    it("returns group") {
                        mockAppSettingsStore.stubbedRemoteRoomType = .group
                        
                        expect(sut.roomType).to(equal(.group))
                    }
                }
                
                context("when remoteRoomType is nil") {
                    beforeEach {
                        mockAppSettingsStore.stubbedRemoteRoomType = nil
                    }
                    
                    context("when target is community") {
                        it("returns peerToPeer") {
                            mockAppInfoStore.stubbedAppInfo = .stub(target: .videoCommunity)
                            
                            expect(sut.roomType).to(equal(.peerToPeer))
                        }
                    }
                    
                    context("when target is internal") {
                        beforeEach {
                            mockAppInfoStore.stubbedAppInfo = .stub(target: .videoInternal)
                        }

                        context("when topology setting is go") {
                            it("returns go") {
                                mockAppSettingsStore.stubbedTopology = .go

                                expect(sut.roomType).to(equal(.go))
                            }
                        }

                        context("when topology setting is group") {
                            it("returns group") {
                                mockAppSettingsStore.stubbedTopology = .group

                                expect(sut.roomType).to(equal(.group))
                            }
                        }

                        context("when topology setting is groupSmall") {
                            it("returns groupSmall") {
                                mockAppSettingsStore.stubbedTopology = .groupSmall

                                expect(sut.roomType).to(equal(.groupSmall))
                            }
                        }
                        
                        context("when topology setting is peerToPeer") {
                            it("returns peerToPeer") {
                                mockAppSettingsStore.stubbedTopology = .peerToPeer

                                expect(sut.roomType).to(equal(.peerToPeer))
                            }
                        }
                    }
                }
            }
            
            describe("set") {
                context("when newValue is different than setting") {
                    beforeEach {
                        mockAppSettingsStore.stubbedRemoteRoomType = nil
                    }
                    
                    context("when newValue is group") {
                        it("sets videoCodec setting to vp8SimulcastVGA") {
                            sut.roomType = .group

                            expect(mockAppSettingsStore.invokedVideoCodec).to(equal(.vp8SimulcastVGA))
                            expect(mockAppSettingsStore.invokedRemoteRoomType).to(equal(.group))
                        }
                    }

                    context("when newValue is groupSmall") {
                        it("sets videoCodec setting to vp8SimulcastVGA") {
                            sut.roomType = .groupSmall

                            expect(mockAppSettingsStore.invokedVideoCodec).to(equal(.vp8SimulcastVGA))
                            expect(mockAppSettingsStore.invokedRemoteRoomType).to(equal(.groupSmall))
                        }
                    }

                    context("when newValue is unknown") {
                        it("sets videoCodec setting to vp8SimulcastVGA") {
                            sut.roomType = .unknown

                            expect(mockAppSettingsStore.invokedVideoCodec).to(equal(.vp8SimulcastVGA))
                            expect(mockAppSettingsStore.invokedRemoteRoomType).to(equal(.unknown))
                        }
                    }

                    context("when newValue is peerToPeer") {
                        it("sets videoCodec setting to vp8") {
                            sut.roomType = .peerToPeer

                            expect(mockAppSettingsStore.invokedVideoCodec).to(equal(.vp8))
                            expect(mockAppSettingsStore.invokedRemoteRoomType).to(equal(.peerToPeer))
                        }
                    }

                    context("when newValue is go") {
                        it("sets videoCodec setting to vp8") {
                            sut.roomType = .go

                            expect(mockAppSettingsStore.invokedVideoCodec).to(equal(.vp8))
                            expect(mockAppSettingsStore.invokedRemoteRoomType).to(equal(.go))
                        }
                    }
                }
                
                context("when newValue is not different from setting") {
                    it("does not update videoCodec setting") {
                        mockAppSettingsStore.stubbedRemoteRoomType = .peerToPeer
                        
                        sut.roomType = .peerToPeer
                        
                        expect(mockAppSettingsStore.invokedVideoCodecSetter).to(beFalse())
                        expect(mockAppSettingsStore.invokedRemoteRoomTypeSetter).to(beFalse())
                    }
                }
            }
        }
    }
}
