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

import Quick
import Nimble

@testable import VideoApp

class AhoyAuthStoreSpec: QuickSpec {
    override func spec() {
        var sut: AhoyAuthStore!
        var mockAPI: MockTwilioVideoAppAPI!
        var mockAppSettingsStore: MockAppSettingsStore!
        var mockFirebaseAuthStore: MockFirebaseAuthStore!
        
        beforeEach {
            mockAPI = MockTwilioVideoAppAPI()
            mockAppSettingsStore = MockAppSettingsStore()
            mockFirebaseAuthStore = MockFirebaseAuthStore()
            sut = AhoyAuthStore(
                api: mockAPI,
                appSettingsStore: mockAppSettingsStore,
                firebaseAuthStore: mockFirebaseAuthStore
            )
        }

        describe("fetchTwilioAccessToken") {
            var invokedCompletionCount = 0
            var invokedCompletionParameters: (accessToken: String?, error: Error?)?

            beforeEach {
                invokedCompletionCount = 0
                invokedCompletionParameters = nil
            }
            
            func fetchTwilioAccessToken(
                roomName: String = "",
                firebaseResult: (String?, Error?) = (nil, nil),
                firebaseDisplayName: String = "",
                userIdentitySetting: String = "",
                apiEnvironmentSetting: APIEnvironment = .production,
                topologySetting: Topology = .group,
                twilioResult: (String?, Error?) = (nil, nil)
            ) {
                mockFirebaseAuthStore.stubbedFetchAccessTokenCompletionResult = firebaseResult
                mockFirebaseAuthStore.stubbedUserDisplayName = firebaseDisplayName
                mockAppSettingsStore.stubbedUserIdentity = userIdentitySetting
                mockAppSettingsStore.stubbedApiEnvironment = apiEnvironmentSetting
                mockAppSettingsStore.stubbedTopology = topologySetting
                mockAPI.stubbedRetrieveAccessTokenCompletionBlockResult = twilioResult

                sut.fetchTwilioAccessToken(roomName: roomName) { accessToken, error in
                    invokedCompletionCount += 1
                    invokedCompletionParameters = (accessToken, error)
                }
            }
            
            describe("fetchAccessToken") {
                it("is called once") {
                    fetchTwilioAccessToken()
                    
                    expect(mockFirebaseAuthStore.invokedFetchAccessTokenCount).to(equal(1))
                }
                
                context("when Firebase accessToken is nil") {
                    context("when Firebase error is nil") {
                        it("calls completion with nil accessToken and nil error") {
                            fetchTwilioAccessToken(firebaseResult: (nil, nil))
                            
                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters?.accessToken).to(beNil())
                            expect(invokedCompletionParameters?.error).to(beNil())
                        }
                    }

                    context("when Firebase error is not nil") {
                        it("calls completion with nil accessToken and Firebase error") {
                            let error = NSError()
                            
                            fetchTwilioAccessToken(firebaseResult: (nil, error))
                            
                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters?.accessToken).to(beNil())
                            expect(invokedCompletionParameters?.error).to(be(error))
                        }
                    }
                }
                
                context("when Firebase accesstoken is not nil") {
                    it("calls retrieveAccessToken") {
                        fetchTwilioAccessToken(firebaseResult: ("", nil))
                        
                        expect(mockAPI.invokedRetrieveAccessTokenCount).to(equal(1))
                    }
                }
            }
            
            describe("retrieveAccessToken") {
                context("when userDisplayName is foo") {
                    context("when userIdentity setting is empty") {
                        it("is called with foo identity") {
                            fetchTwilioAccessToken(firebaseResult: ("", nil), firebaseDisplayName: "foo", userIdentitySetting: "")

                            expect(mockAPI.invokedRetrieveAccessTokenParameters?.identity).to(equal("foo"))
                        }
                    }

                    context("when userIdentity setting is bar") {
                        it("is called with bar identity") {
                            fetchTwilioAccessToken(firebaseResult: ("", nil), firebaseDisplayName: "foo", userIdentitySetting: "bar")

                            expect(mockAPI.invokedRetrieveAccessTokenParameters?.identity).to(equal("bar"))
                        }
                    }
                }

                context("when userDisplayName is bar") {
                    context("when userIdentity setting is empty") {
                        it("is called with bar identity") {
                            fetchTwilioAccessToken(firebaseResult: ("", nil), firebaseDisplayName: "bar", userIdentitySetting: "")

                            expect(mockAPI.invokedRetrieveAccessTokenParameters?.identity).to(equal("bar"))
                        }
                    }

                    context("when userIdentity setting is foo") {
                        it("is called with foo identity") {
                            fetchTwilioAccessToken(firebaseResult: ("", nil), firebaseDisplayName: "bar", userIdentitySetting: "foo")

                            expect(mockAPI.invokedRetrieveAccessTokenParameters?.identity).to(equal("foo"))
                        }
                    }
                }

                context("when roomName is foo") {
                    it("is called with foo roomName") {
                        fetchTwilioAccessToken(roomName: "foo", firebaseResult: ("", nil))
                        
                        expect(mockAPI.invokedRetrieveAccessTokenParameters?.roomName).to(equal("foo"))
                    }
                }
                
                context("when roomName is bar") {
                    it("is called with bar roomName") {
                        fetchTwilioAccessToken(roomName: "bar", firebaseResult: ("", nil))

                        expect(mockAPI.invokedRetrieveAccessTokenParameters?.roomName).to(equal("bar"))
                    }
                }

                context("when Firebase accessToken is foo") {
                    it("is called with foo authToken") {
                        fetchTwilioAccessToken(firebaseResult: ("foo", nil))

                        expect(mockAPI.invokedRetrieveAccessTokenParameters?.authToken).to(equal("foo"))
                    }
                }

                context("when Firebase token is bar") {
                    it("is called with bar authToken") {
                        fetchTwilioAccessToken(firebaseResult: ("bar", nil))

                        expect(mockAPI.invokedRetrieveAccessTokenParameters?.authToken).to(equal("bar"))
                    }
                }

                context("when apiEnvironment is production") {
                    it("is called with production environment") {
                        fetchTwilioAccessToken(firebaseResult: ("", nil), apiEnvironmentSetting: .production)

                        expect(mockAPI.invokedRetrieveAccessTokenParameters?.environment).to(equal(.production))
                    }
                }
                
                context("when apiEnvironment is development") {
                    it("is called with development environment") {
                        fetchTwilioAccessToken(firebaseResult: ("", nil), apiEnvironmentSetting: .development)

                        expect(mockAPI.invokedRetrieveAccessTokenParameters?.environment).to(equal(.development))
                    }
                }
                
                context("when topology is group") {
                    it("is called with group topology") {
                        fetchTwilioAccessToken(firebaseResult: ("", nil), topologySetting: .group)

                        expect(mockAPI.invokedRetrieveAccessTokenParameters?.topology).to(equal(.group))
                    }
                }

                context("when topology is P2P") {
                    it("is called with P2P topology") {
                        fetchTwilioAccessToken(firebaseResult: ("", nil), topologySetting: .peerToPeer)

                        expect(mockAPI.invokedRetrieveAccessTokenParameters?.topology).to(equal(.P2P))
                    }
                }

                describe("completion") {
                    context("when Twilio accessToken is foo") {
                        it("calls completion with foo accessToken") {
                            fetchTwilioAccessToken(firebaseResult: ("", nil), twilioResult: ("foo", nil))

                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters?.accessToken).to(equal("foo"))
                        }
                    }
                    
                    context("when Twilio accessToken is nil") {
                        it("calls completion with nil accessToken") {
                            fetchTwilioAccessToken(firebaseResult: ("", nil), twilioResult: (nil, nil))

                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters?.accessToken).to(beNil())
                        }
                    }

                    context("when error is not nil") {
                        it("calls completion with Twilio error") {
                            let error = NSError()
                            fetchTwilioAccessToken(firebaseResult: ("", nil), twilioResult: (nil, error))

                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters?.error).to(be(error))
                        }
                    }

                    context("when error is nil") {
                        it("calls completion with nil error") {
                            fetchTwilioAccessToken(firebaseResult: ("", nil), twilioResult: (nil, nil))

                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters?.error).to(beNil())
                        }
                    }
                }
            }
        }
    }
}
