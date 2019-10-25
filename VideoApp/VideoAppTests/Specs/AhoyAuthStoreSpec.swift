//
//  AhoyAuthStoreSpec.swift
//  Video-TwilioTests
//
//  Created by Tim Rozum on 10/16/19.
//  Copyright © 2019 Twilio, Inc. All rights reserved.
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

        describe("fetchAccessToken") {
            var invokedCompletionCount = 0
            var invokedCompletionParameters: (accessToken: String?, error: Error?)?

            beforeEach {
                invokedCompletionCount = 0
                invokedCompletionParameters = nil
            }
            
            func fetchAccessToken(
                roomName: String = "",
                firebaseResult: (String?, Error?) = (nil, nil),
                firebaseDisplayName: String = "",
                appSettings: AppSettings = .stub(),
                twilioResult: (String?, Error?) = (nil, nil)
            ) {
                mockFirebaseAuthStore.stubbedFetchAccessTokenCompletionResult = firebaseResult
                mockFirebaseAuthStore.stubbedUserDisplayName = firebaseDisplayName
                mockAppSettingsStore.stubbedAppSettings = appSettings
                mockAPI.stubbedRetrieveAccessTokenCompletionBlockResult = twilioResult

                sut.fetchTwilioAccessToken(roomName: roomName) { accessToken, error in
                    invokedCompletionCount += 1
                    invokedCompletionParameters = (accessToken, error)
                }
            }
            
            describe("getIDToken") {
                it("is called once") {
                    fetchAccessToken()
                    
                    expect(mockFirebaseAuthStore.invokedFetchAccessTokenCount).to(equal(1))
                }
                
                context("when Firebase token is nil") {
                    context("when Firebase error is nil") {
                        it("calls completion with nil token and nil error") {
                            fetchAccessToken(firebaseResult: (nil, nil))
                            
                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters?.accessToken).to(beNil())
                            expect(invokedCompletionParameters?.error).to(beNil())
                        }
                    }

                    context("when Firebase error is not nil") {
                        it("calls completion with nil token and Firebase error") {
                            let error = NSError()
                            
                            fetchAccessToken(firebaseResult: (nil, error))
                            
                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters?.accessToken).to(beNil())
                            expect(invokedCompletionParameters?.error).to(be(error))
                        }
                    }
                }
                
                context("when Firebase token is not nil") {
                    it("calls retrieveAccessToken") {
                        fetchAccessToken(firebaseResult: ("", nil))
                        
                        expect(mockAPI.invokedRetrieveAccessTokenCount).to(equal(1))
                    }
                }
            }
            
            describe("retrieveAccessToken") {
                context("when currentUserDisplayName is foo") {
                    it("is called with foo identity") {
                        fetchAccessToken(firebaseResult: ("", nil), firebaseDisplayName: "foo")

                        expect(mockAPI.invokedRetrieveAccessTokenParameters?.identity).to(equal("foo"))
                    }
                }
                
                context("when currentUserDisplayName is bar") {
                    it("is called with bar identity") {
                        fetchAccessToken(firebaseResult: ("", nil), firebaseDisplayName: "bar")

                        expect(mockAPI.invokedRetrieveAccessTokenParameters?.identity).to(equal("bar"))
                    }
                }

                context("when roomName is foo") {
                    it("is called with foo roomName") {
                        fetchAccessToken(roomName: "foo", firebaseResult: ("", nil))
                        
                        expect(mockAPI.invokedRetrieveAccessTokenParameters?.roomName).to(equal("foo"))
                    }
                }
                
                context("when roomName is bar") {
                    it("is called with bar roomName") {
                        fetchAccessToken(roomName: "bar", firebaseResult: ("", nil))

                        expect(mockAPI.invokedRetrieveAccessTokenParameters?.roomName).to(equal("bar"))
                    }
                }

                context("when Firebase token is foo") {
                    it("is called with foo token") {
                        fetchAccessToken(firebaseResult: ("foo", nil))

                        expect(mockAPI.invokedRetrieveAccessTokenParameters?.authToken).to(equal("foo"))
                    }
                }

                context("when Firebase token is bar") {
                    it("is called with bar token") {
                        fetchAccessToken(firebaseResult: ("bar", nil))

                        expect(mockAPI.invokedRetrieveAccessTokenParameters?.authToken).to(equal("bar"))
                    }
                }

                context("when environment is production") {
                    it("is called with production environment") {
                        fetchAccessToken(firebaseResult: ("", nil), appSettings: .stub(environment: .production))

                        expect(mockAPI.invokedRetrieveAccessTokenParameters?.environment).to(equal(.production))
                    }
                }

                context("when environment is development") {
                    it("is called with development environment") {
                        fetchAccessToken(firebaseResult: ("", nil), appSettings: .stub(environment: .development))

                        expect(mockAPI.invokedRetrieveAccessTokenParameters?.environment).to(equal(.development))
                    }
                }

                context("when topology is group") {
                    it("is called with group topology") {
                        fetchAccessToken(firebaseResult: ("", nil), appSettings: .stub(topology: .group))

                        expect(mockAPI.invokedRetrieveAccessTokenParameters?.topology).to(equal(.group))
                    }
                }

                context("when topology is P2P") {
                    it("is called with P2P topology") {
                        fetchAccessToken(firebaseResult: ("", nil), appSettings: .stub(topology: .P2P))

                        expect(mockAPI.invokedRetrieveAccessTokenParameters?.topology).to(equal(.P2P))
                    }
                }

                describe("completion") {
                    context("when Twilio accessToken is foo") {
                        it("calls completion with foo accessToken") {
                            fetchAccessToken(firebaseResult: ("", nil), twilioResult: ("foo", nil))

                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters?.accessToken).to(equal("foo"))
                        }
                    }
                    
                    context("when Twilio accessToken is nil") {
                        it("calls completion with nil accessToken") {
                            fetchAccessToken(firebaseResult: ("", nil), twilioResult: (nil, nil))

                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters?.accessToken).to(beNil())
                        }
                    }

                    context("when error is not nil") {
                        it("calls completion with Twilio error") {
                            let error = NSError()
                            fetchAccessToken(firebaseResult: ("", nil), twilioResult: (nil, error))

                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters?.error).to(be(error))
                        }
                    }

                    context("when error is nil") {
                        it("calls completion with nil error") {
                            fetchAccessToken(firebaseResult: ("", nil), twilioResult: (nil, nil))

                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters?.error).to(beNil())
                        }
                    }
                }
            }
        }
    }
}
