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

class CommunityAuthStoreSpec: QuickSpec {
    override func spec() {
        var sut: CommunityAuthStore!
        var mockAPI: MockAPI!
        var mockAppSettingsStore: MockAppSettingsStore!
        var mockKeychainStore: MockKeychainStore!
        var mockDelegate: MockAuthStoreWritingDelgate!
        var mockRemoteConfigStore: MockRemoteConfigStore!

        beforeEach {
            mockAPI = MockAPI()
            mockAppSettingsStore = MockAppSettingsStore()
            mockKeychainStore = MockKeychainStore()
            mockDelegate = MockAuthStoreWritingDelgate()
            mockRemoteConfigStore = MockRemoteConfigStore()
            
            sut = CommunityAuthStore(
                api: mockAPI,
                appSettingsStore: mockAppSettingsStore,
                keychainStore: mockKeychainStore,
                remoteConfigStore: mockRemoteConfigStore
            )
            sut.delegate = mockDelegate
        }
        
        describe("isSignedIn") {
            context("when passcode is nil") {
                it("returns false") {
                    mockKeychainStore.stubbedPasscode = nil

                    expect(sut.isSignedIn).to(beFalse())
                }
            }

            context("when passcode is foo") {
                it("returns true") {
                    mockKeychainStore.stubbedPasscode = "foo"

                    expect(sut.isSignedIn).to(beTrue())
                }
            }
        }
        
        describe("passcode") {
            context("when passcode is nil") {
                it("returns nil") {
                    mockKeychainStore.stubbedPasscode = nil

                    expect(sut.passcode).to(beNil())
                }
            }

            context("when passcode is foo") {
                it("returns foo") {
                    mockKeychainStore.stubbedPasscode = "foo"

                    expect(sut.passcode).to(equal("foo"))
                }
            }
        }
        
        describe("userDisplayName") {
            context("when userIdentity is foo") {
                it("returns foo") {
                    mockAppSettingsStore.stubbedUserIdentity = "foo"
                    
                    expect(sut.userDisplayName).to(equal("foo"))
                }
            }

            context("when userIdentity is bar") {
                it("returns bar") {
                    mockAppSettingsStore.stubbedUserIdentity = "bar"
                    
                    expect(sut.userDisplayName).to(equal("bar"))
                }
            }
        }
        
        describe("start") {
            context("when passcode is nil") {
                it("does not configure API") {
                    mockKeychainStore.stubbedPasscode = nil
                    
                    sut.start()
                    
                    expect(mockAPI.invokedConfigSetter).to(beFalse())
                }
            }

            context("when passcode is 25469852355647") {
                it("configures API with video-app-5235-5647-dev.twil.io host") {
                    mockKeychainStore.stubbedPasscode = "25469852355647"
                    
                    sut.start()
                    
                    expect(mockAPI.invokedConfigSetterCount).to(equal(1))
                    expect(mockAPI.invokedConfig).to(equal(APIConfig(host: "video-app-5235-5647-dev.twil.io")))
                }
            }
        }

        describe("signIn with userIdentity and passcode") {
            var invokedCompletionCount = 0
            var invokedCompletionParameters: (error: AuthError?, Void)?

            beforeEach {
                invokedCompletionCount = 0
                invokedCompletionParameters = nil
            }
            
            func signIn(
                userIdentity: String = "",
                passcode: String = "12546985321456",
                apiResult: Result<Any, APIError> = .success(CreateTwilioAccessTokenResponse.stub())
            ) {
                mockAPI.stubbedRequestCompletionResult = apiResult
                sut.signIn(userIdentity: userIdentity, passcode: passcode) { error in
                    invokedCompletionCount += 1
                    invokedCompletionParameters = (error, ())
                }
            }
            
            describe("configureAPI") {
                context("when passcode is new format") {
                    context("when passcode is 25469852355627") {
                        it("configures API with video-app-5235-5627-dev.twil.io host") {
                            signIn(passcode: "25469852355627")
                            
                            expect(mockAPI.invokedConfigSetterCount).to(equal(1))
                            expect(mockAPI.invokedConfig).to(equal(APIConfig(host: "video-app-5235-5627-dev.twil.io")))
                        }
                    }
                }
                
                context("when passcode is old format") {
                    context("when passcode is 6548521749") {
                        it("configures API with video-app-1749-dev.twil.io host") {
                            signIn(passcode: "6548521749")
                            
                            expect(mockAPI.invokedConfigSetterCount).to(equal(1))
                            expect(mockAPI.invokedConfig).to(equal(APIConfig(host: "video-app-1749-dev.twil.io")))
                        }
                    }
                }
                
                context("when passcode is invalid format") {
                    context("when passcode is empty string") {
                        it("calls completion with passcodeIncorrect error") {
                            signIn(passcode: "")

                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters?.error).to(equal(.passcodeIncorrect))
                            expect(mockAPI.invokedRequestCount).to(equal(0))
                        }
                    }
                }
            }
            
            describe("request") {
                it("is called once") {
                    signIn()
                    
                    expect(mockAPI.invokedRequestCount).to(equal(1))
                }

                context("when userIdentity is foo") {
                    it("is called with foo userIdentity") {
                        signIn(userIdentity: "foo")
                        
                        expect((mockAPI.invokedRequestParameters?.request as? CreateTwilioAccessTokenRequest)?.parameters.userIdentity).to(equal("foo"))
                    }
                }

                context("when userIdentity is bar") {
                    it("is called with bar userIdentity") {
                        signIn(userIdentity: "bar")

                        expect((mockAPI.invokedRequestParameters?.request as? CreateTwilioAccessTokenRequest)?.parameters.userIdentity).to(equal("bar"))
                    }
                }

                context("when passcode is 15648298735694") {
                    it("is called with 15648298735694 passcode") {
                        signIn(passcode: "15648298735694")
                        
                        expect((mockAPI.invokedRequestParameters?.request as? CreateTwilioAccessTokenRequest)?.parameters.passcode).to(equal("15648298735694"))
                    }
                }

                context("when passcode is 56487269813982") {
                    it("is called with 56487269813982 passcode") {
                        signIn(passcode: "56487269813982")
                        
                        expect((mockAPI.invokedRequestParameters?.request as? CreateTwilioAccessTokenRequest)?.parameters.passcode).to(equal("56487269813982"))
                    }
                }

                it("is called with createRoom set to false") {
                    signIn()
                    
                    expect((mockAPI.invokedRequestParameters?.request as? CreateTwilioAccessTokenRequest)?.parameters.createRoom).to(beFalse())
                }

                context("when result is success") {
                    context("when passcode is 21564852315698") {
                        it("stores 21564852315698 passcode in keychain") {
                            signIn(passcode: "21564852315698", apiResult: .success(CreateTwilioAccessTokenResponse.stub()))
                            
                            expect(mockKeychainStore.invokedPasscodeSetterCount).to(equal(1))
                            expect(mockKeychainStore.invokedPasscode).to(equal("21564852315698"))
                        }
                    }

                    context("when passcode is 65984128742143") {
                        it("stores 65984128742143 passcode in keychain") {
                            signIn(passcode: "65984128742143", apiResult: .success(CreateTwilioAccessTokenResponse.stub()))
                            
                            expect(mockKeychainStore.invokedPasscodeSetterCount).to(equal(1))
                            expect(mockKeychainStore.invokedPasscode).to(equal("65984128742143"))
                        }
                    }

                    context("when userIdentity is foo") {
                        it("sets userIdentity setting to foo") {
                            signIn(userIdentity: "foo", apiResult: .success(CreateTwilioAccessTokenResponse.stub()))

                            expect(mockAppSettingsStore.invokedUserIdentitySetterCount).to(equal(1))
                            expect(mockAppSettingsStore.invokedUserIdentity).to(equal("foo"))
                        }
                    }
                    
                    context("when userIdentity is bar") {
                        it("sets userIdentity setting to bar") {
                            signIn(userIdentity: "bar", apiResult: .success(CreateTwilioAccessTokenResponse.stub()))

                            expect(mockAppSettingsStore.invokedUserIdentitySetterCount).to(equal(1))
                            expect(mockAppSettingsStore.invokedUserIdentity).to(equal("bar"))
                        }
                    }

                    context("when roomType is nil") {
                        it("does not update remoteConfigStore") {
                            signIn(apiResult: .success(CreateTwilioAccessTokenResponse.stub(roomType: nil)))

                            expect(mockRemoteConfigStore.invokedRoomTypeSetter).to(beFalse())
                        }
                    }
                    
                    context("when roomType is peerToPeer") {
                        it("updates remoteConfigStore") {
                            signIn(apiResult: .success(CreateTwilioAccessTokenResponse.stub(roomType: .peerToPeer)))

                            expect(mockRemoteConfigStore.invokedRoomTypeSetterCount).to(equal(1))
                            expect(mockRemoteConfigStore.invokedRoomType).to(equal(.peerToPeer))
                        }
                    }

                    it("calls completion with nil error") {
                        signIn(apiResult: .success(CreateTwilioAccessTokenResponse.stub()))
                        
                        expect(invokedCompletionCount).to(equal(1))
                        expect(invokedCompletionParameters?.error).to(beNil())
                    }
                }

                context("when result is failure") {
                    it("sets API config to nil") {
                        signIn(apiResult: .failure(.message(message: "")))
                        
                        expect(mockAPI.invokedConfig).to(beNil())
                    }

                    context("when error is foo") {
                        it("calls completion with foo error") {
                            signIn(apiResult: .failure(.message(message: "foo")))

                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters?.error).to(equal(.message(message: "foo")))
                        }
                    }
                    
                    context("when error is bar") {
                        it("calls completion with bar error") {
                            signIn(apiResult: .failure(.message(message: "bar")))

                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters?.error).to(equal(.message(message: "bar")))
                        }
                    }
                }
            }
        }
        
        describe("signOut") {
            beforeEach {
                sut.signOut()
            }
            
            it("sets passcode to nil") {
                expect(mockKeychainStore.invokedPasscodeSetterCount).to(equal(1))
                expect(mockKeychainStore.invokedPasscode).to(beNil())
            }
            
            it("resets app settings") {
                expect(mockAppSettingsStore.invokedResetCount).to(equal(1))
            }
            
            it("sets API config to nil") {
                expect(mockAPI.invokedConfigSetterCount).to(equal(1))
                expect(mockAPI.invokedConfig).to(beNil())
            }
            
            it("calls didSignOut on delegate") {
                expect(mockDelegate.invokedDidSignOutCount).to(equal(1))
            }
        }
        
        describe("openURL") {
            it("returns false") {
                expect(sut.openURL(URL(string: "www.twilio.com")!)).to(equal(false))
            }
        }
    }
}
