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
        var mockAppSettingsStore: MockAppSettingsStore!
        var mockKeychainStore: MockKeychainStore!
        var mockAPI: MockAPI!
        var mockDelegate: MockAuthStoreWritingDelgate!

        beforeEach {
            mockAppSettingsStore = MockAppSettingsStore()
            mockKeychainStore = MockKeychainStore()
            mockAPI = MockAPI()
            mockDelegate = MockAuthStoreWritingDelgate()
            sut = CommunityAuthStore(
                appSettingsStore: mockAppSettingsStore,
                keychainStore: mockKeychainStore,
                api: mockAPI
            )
            sut.delegate = mockDelegate
        }
        
        describe("isSignedIn") {
            context("when passcode is nil") {
                it("returns nil") {
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
                result: Result<Any, APIError> = .success(CreateTwilioAccessTokenResponse.stub())
            ) {
                mockAPI.stubbedRequestCompletionResult = result
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
                        
                        expect((mockAPI.invokedRequestParameters?.request as? CreateTwilioAccessTokenRequest)?.parameters.userIdentity).to(equal("foo"))
                    }
                }

                context("when userIdentity is bar") {
                    it("is called with bar userIdentity") {
                        signIn(userIdentity: "bar")

                        expect((mockAPI.invokedRequestParameters?.request as? CreateTwilioAccessTokenRequest)?.parameters.userIdentity).to(equal("bar"))
                    }
                }

                context("when passcode is foo") {
                    it("is called with foo passcode") {
                        signIn(passcode: "foo")
                        
                        expect((mockAPI.invokedRequestParameters?.request as? CreateTwilioAccessTokenRequest)?.parameters.passcode).to(equal("foo"))
                    }
                }

                context("when passcode is bar") {
                    it("is called with bar passcode") {
                        signIn(passcode: "bar")
                        
                        expect((mockAPI.invokedRequestParameters?.request as? CreateTwilioAccessTokenRequest)?.parameters.passcode).to(equal("bar"))
                    }
                }

                it("is called with empty roomName") {
                    signIn()
                    
                    expect((mockAPI.invokedRequestParameters?.request as? CreateTwilioAccessTokenRequest)?.parameters.roomName).to(equal(""))
                }

                context("when result is success") {
                    context("when passcode is foo") {
                        it("stores foo passcode in keychain") {
                            signIn(passcode: "foo", result: .success(CreateTwilioAccessTokenResponse.stub()))
                            
                            expect(mockKeychainStore.invokedPasscodeSetterCount).to(equal(1))
                            expect(mockKeychainStore.invokedPasscode).to(equal("foo"))
                        }
                    }

                    context("when passcode is bar") {
                        it("stores bar passcode in keychain") {
                            signIn(passcode: "bar", result: .success(CreateTwilioAccessTokenResponse.stub()))
                            
                            expect(mockKeychainStore.invokedPasscodeSetterCount).to(equal(1))
                            expect(mockKeychainStore.invokedPasscode).to(equal("bar"))
                        }
                    }

                    context("when userIdentity is foo") {
                        it("sets userIdentity setting to foo") {
                            signIn(userIdentity: "foo", result: .success(CreateTwilioAccessTokenResponse.stub()))

                            expect(mockAppSettingsStore.invokedUserIdentitySetterCount).to(equal(1))
                            expect(mockAppSettingsStore.invokedUserIdentity).to(equal("foo"))
                        }
                    }
                    
                    context("when userIdentity is bar") {
                        it("sets userIdentity setting to bar") {
                            signIn(userIdentity: "bar", result: .success(CreateTwilioAccessTokenResponse.stub()))

                            expect(mockAppSettingsStore.invokedUserIdentitySetterCount).to(equal(1))
                            expect(mockAppSettingsStore.invokedUserIdentity).to(equal("bar"))
                        }
                    }

                    it("calls completion with nil error") {
                        signIn(result: .success(CreateTwilioAccessTokenResponse.stub()))
                        
                        expect(invokedCompletionCount).to(equal(1))
                        expect(invokedCompletionParameters?.error).to(beNil())
                    }
                }

                context("when result is failure") {
                    it("sets API config to nil") {
                        signIn(result: .failure(.passcodeExpired))
                        
                        expect(mockAPI.invokedConfig).to(beNil())
                    }

                    context("when error is expiredPasscode error") {
                        it("calls completion with expiredPasscode error") {
                            signIn(result: .failure(.passcodeExpired))

                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters?.error).to(equal(.passcodeExpired))
                        }
                    }
                    
                    context("when error is notConnectedToInternet error") {
                        it("calls completion with notConnectedToInternet error") {
                            signIn(result: .failure(.notConnectedToInternet))

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
        
        describe("fetchTwilioAccessToken") {
            var invokedCompletionCount = 0
            var invokedCompletionParameters: (accessToken: String?, error: Error?)?

            beforeEach {
                invokedCompletionCount = 0
                invokedCompletionParameters = nil
            }
            
            func fetchTwilioAccessToken(
                passcode: String? = nil,
                userIdentity: String = "",
                roomName: String = "",
                result: Result<Any, APIError> = .success(CreateTwilioAccessTokenResponse.stub())
            ) {
                mockKeychainStore.stubbedPasscode = passcode
                mockAppSettingsStore.stubbedUserIdentity = userIdentity
                mockAPI.stubbedRequestCompletionResult = result
                sut.fetchTwilioAccessToken(roomName: roomName) { accessToken, error in
                    invokedCompletionCount += 1
                    invokedCompletionParameters = (accessToken, error)
                }
            }
            
            describe("request") {
                it("is called once") {
                    fetchTwilioAccessToken()
                    
                    expect(mockAPI.invokedRequestCount).to(equal(1))
                }

                context("when passcode is nil") {
                    it("is called with empty passcode") {
                        fetchTwilioAccessToken(passcode: nil)
                        
                        expect((mockAPI.invokedRequestParameters?.request as? CreateTwilioAccessTokenRequest)?.parameters.passcode).to(equal(""))
                    }
                }

                context("when passcode is foo") {
                    it("is called with foo passcode") {
                        fetchTwilioAccessToken(passcode: "foo")
                        
                        expect((mockAPI.invokedRequestParameters?.request as? CreateTwilioAccessTokenRequest)?.parameters.passcode).to(equal("foo"))
                    }
                }

                context("when userIdentity is foo") {
                    it("is called with foo userIdentity") {
                        fetchTwilioAccessToken(userIdentity: "foo")
                        
                        expect((mockAPI.invokedRequestParameters?.request as? CreateTwilioAccessTokenRequest)?.parameters.userIdentity).to(equal("foo"))
                    }
                }

                context("when userIdentity is bar") {
                    it("is called with bar userIdentity") {
                        fetchTwilioAccessToken(userIdentity: "bar")
                        
                        expect((mockAPI.invokedRequestParameters?.request as? CreateTwilioAccessTokenRequest)?.parameters.userIdentity).to(equal("bar"))
                    }
                }

                context("when roomName is foo") {
                    it("is called with foo roomName") {
                        fetchTwilioAccessToken(roomName: "foo")
                        
                        expect((mockAPI.invokedRequestParameters?.request as? CreateTwilioAccessTokenRequest)?.parameters.roomName).to(equal("foo"))
                    }
                }

                context("when roomName is bar") {
                    it("is called with bar roomName") {
                        fetchTwilioAccessToken(roomName: "bar")
                        
                        expect((mockAPI.invokedRequestParameters?.request as? CreateTwilioAccessTokenRequest)?.parameters.roomName).to(equal("bar"))
                    }
                }
                
                context("when result is success") {
                    context("when token is foo") {
                        it("calls completion with foo token") {
                            fetchTwilioAccessToken(result: .success(CreateTwilioAccessTokenResponse.stub(token: "foo")))
                            
                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters?.accessToken).to(equal("foo"))
                            expect(invokedCompletionParameters?.error).to(beNil())
                        }
                    }
                    
                    context("when token is bar") {
                        it("calls completion with bar token") {
                            fetchTwilioAccessToken(result: .success(CreateTwilioAccessTokenResponse.stub(token: "bar")))
                            
                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters?.accessToken).to(equal("bar"))
                            expect(invokedCompletionParameters?.error).to(beNil())
                        }
                    }
                }

                context("when result is failure") {
                    context("when error is expiredPasscode") {
                        it("calls completion with expiredPasscode error") {
                            fetchTwilioAccessToken(result: .failure(.passcodeExpired))
                            
                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters?.accessToken).to(beNil())
                            expect(invokedCompletionParameters?.error as? APIError).to(equal(.passcodeExpired))
                        }
                    }

                    context("when error is notConnectedToInternet") {
                        it("calls completion with notConnectedToInternet error") {
                            fetchTwilioAccessToken(result: .failure(.notConnectedToInternet))
                            
                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters?.accessToken).to(beNil())
                            expect(invokedCompletionParameters?.error as? APIError).to(equal(.notConnectedToInternet))
                        }
                    }
                }
            }
        }
    }
}
