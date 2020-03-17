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

        beforeEach {
            mockAPI = MockAPI()
            mockAppSettingsStore = MockAppSettingsStore()
            mockKeychainStore = MockKeychainStore()
            mockDelegate = MockAuthStoreWritingDelgate()
            sut = CommunityAuthStore(
                api: mockAPI,
                appSettingsStore: mockAppSettingsStore,
                keychainStore: mockKeychainStore
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

            context("when passcode is 2546985235") {
                it("configures API with video-app-5235-dev.twil.io host") {
                    mockKeychainStore.stubbedPasscode = "2546985235"
                    
                    sut.start()
                    
                    expect(mockAPI.invokedConfigSetterCount).to(equal(1))
                    expect(mockAPI.invokedConfig).to(equal(APIConfig(host: "video-app-5235-dev.twil.io")))
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
                passcode: String = "",
                apiResult: Result<Any, APIError> = .success(CommunityCreateTwilioAccessTokenResponse.stub())
            ) {
                mockAPI.stubbedRequestCompletionResult = apiResult
                sut.signIn(userIdentity: userIdentity, passcode: passcode) { error in
                    invokedCompletionCount += 1
                    invokedCompletionParameters = (error, ())
                }
            }
            
            describe("configureAPI") {
                context("when passcode is 2546985235") {
                    it("configures API with video-app-5235-dev.twil.io host") {
                        signIn(passcode: "2546985235")
                        
                        expect(mockAPI.invokedConfigSetterCount).to(equal(1))
                        expect(mockAPI.invokedConfig).to(equal(APIConfig(host: "video-app-5235-dev.twil.io")))
                    }
                }

                context("when passcode is 6548521749") {
                    it("configures API with video-app-1749-dev.twil.io host") {
                        signIn(passcode: "6548521749")
                        
                        expect(mockAPI.invokedConfigSetterCount).to(equal(1))
                        expect(mockAPI.invokedConfig).to(equal(APIConfig(host: "video-app-1749-dev.twil.io")))
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
                        
                        expect((mockAPI.invokedRequestParameters?.request as? CommunityCreateTwilioAccessTokenRequest)?.parameters.userIdentity).to(equal("foo"))
                    }
                }

                context("when userIdentity is bar") {
                    it("is called with bar userIdentity") {
                        signIn(userIdentity: "bar")

                        expect((mockAPI.invokedRequestParameters?.request as? CommunityCreateTwilioAccessTokenRequest)?.parameters.userIdentity).to(equal("bar"))
                    }
                }

                context("when passcode is foo") {
                    it("is called with foo passcode") {
                        signIn(passcode: "foo")
                        
                        expect((mockAPI.invokedRequestParameters?.request as? CommunityCreateTwilioAccessTokenRequest)?.parameters.passcode).to(equal("foo"))
                    }
                }

                context("when passcode is bar") {
                    it("is called with bar passcode") {
                        signIn(passcode: "bar")
                        
                        expect((mockAPI.invokedRequestParameters?.request as? CommunityCreateTwilioAccessTokenRequest)?.parameters.passcode).to(equal("bar"))
                    }
                }

                it("is called with empty roomName") {
                    signIn()
                    
                    expect((mockAPI.invokedRequestParameters?.request as? CommunityCreateTwilioAccessTokenRequest)?.parameters.roomName).to(equal(""))
                }

                context("when result is success") {
                    context("when passcode is foo") {
                        it("stores foo passcode in keychain") {
                            signIn(passcode: "foo", apiResult: .success(CommunityCreateTwilioAccessTokenResponse.stub()))
                            
                            expect(mockKeychainStore.invokedPasscodeSetterCount).to(equal(1))
                            expect(mockKeychainStore.invokedPasscode).to(equal("foo"))
                        }
                    }

                    context("when passcode is bar") {
                        it("stores bar passcode in keychain") {
                            signIn(passcode: "bar", apiResult: .success(CommunityCreateTwilioAccessTokenResponse.stub()))
                            
                            expect(mockKeychainStore.invokedPasscodeSetterCount).to(equal(1))
                            expect(mockKeychainStore.invokedPasscode).to(equal("bar"))
                        }
                    }

                    context("when userIdentity is foo") {
                        it("sets userIdentity setting to foo") {
                            signIn(userIdentity: "foo", apiResult: .success(CommunityCreateTwilioAccessTokenResponse.stub()))

                            expect(mockAppSettingsStore.invokedUserIdentitySetterCount).to(equal(1))
                            expect(mockAppSettingsStore.invokedUserIdentity).to(equal("foo"))
                        }
                    }
                    
                    context("when userIdentity is bar") {
                        it("sets userIdentity setting to bar") {
                            signIn(userIdentity: "bar", apiResult: .success(CommunityCreateTwilioAccessTokenResponse.stub()))

                            expect(mockAppSettingsStore.invokedUserIdentitySetterCount).to(equal(1))
                            expect(mockAppSettingsStore.invokedUserIdentity).to(equal("bar"))
                        }
                    }

                    it("calls completion with nil error") {
                        signIn(apiResult: .success(CommunityCreateTwilioAccessTokenResponse.stub()))
                        
                        expect(invokedCompletionCount).to(equal(1))
                        expect(invokedCompletionParameters?.error).to(beNil())
                    }
                }

                context("when result is failure") {
                    it("sets API config to nil") {
                        signIn(apiResult: .failure(.passcodeExpired))
                        
                        expect(mockAPI.invokedConfig).to(beNil())
                    }

                    context("when error is expiredPasscode error") {
                        it("calls completion with expiredPasscode error") {
                            signIn(apiResult: .failure(.passcodeExpired))

                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters?.error).to(equal(.passcodeExpired))
                        }
                    }
                    
                    context("when error is notConnectedToInternet error") {
                        it("calls completion with notConnectedToInternet error") {
                            signIn(apiResult: .failure(.notConnectedToInternet))

                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters?.error).to(equal(.networkError))
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
