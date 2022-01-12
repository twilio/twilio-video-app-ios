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

class TwilioAccessTokenStoreSpec: QuickSpec {
    override func spec() {
        var sut: TwilioAccessTokenStore!
        var mockAPI: MockAPI!
        var mockAppSettingsStore: MockAppSettingsStore!
        var mockAuthStore: MockAuthStore!
        var mockRemoteConfigStore: MockRemoteConfigStore!
        
        beforeEach {
            mockAPI = MockAPI()
            mockAppSettingsStore = MockAppSettingsStore()
            mockAuthStore = MockAuthStore()
            mockRemoteConfigStore = MockRemoteConfigStore()
            sut = TwilioAccessTokenStore(
                api: mockAPI,
                appSettingsStore: mockAppSettingsStore,
                authStore: mockAuthStore,
                remoteConfigStore: mockRemoteConfigStore
            )
        }

        describe("fetchTwilioAccessToken") {
            var invokedCompletionCount = 0
            var invokedCompletionParameters: (result: Result<String, APIError>, Void)?

            beforeEach {
                invokedCompletionCount = 0
                invokedCompletionParameters = nil
            }
            
            func fetchTwilioAccessToken(
                passcode: String? = nil,
                roomName: String = "",
                userIdentity: String = "",
                userDisplayName: String = "",
                apiResult: Result<Any, APIError> = .success(CreateTwilioAccessTokenResponse.stub())
            ) {
                mockAuthStore.stubbedPasscode = passcode
                mockAppSettingsStore.stubbedUserIdentity = userIdentity
                mockAuthStore.stubbedUserDisplayName = userDisplayName
                mockAuthStore.shouldInvokeRefreshIDTokenCompletion = true
                mockAPI.stubbedRequestCompletionResult = apiResult

                sut.fetchTwilioAccessToken(roomName: roomName) { result in
                    invokedCompletionCount += 1
                    invokedCompletionParameters = (result, ())
                }
            }

            it("it calls refreshIDToken once") {
                fetchTwilioAccessToken()
                
                expect(mockAuthStore.invokedRefreshIDTokenCount).to(equal(1))
            }

            describe("request") {
                it("is called once") {
                    fetchTwilioAccessToken()
                    
                    expect(mockAPI.invokedRequestCount).to(equal(1))
                }

                it("is called with createRoom true") {
                    fetchTwilioAccessToken()
                    
                    expect((mockAPI.invokedRequestParameters?.request as? CreateTwilioAccessTokenRequest)?.parameters.createRoom).to(beTrue())
                }

                context("when passcode is nil") {
                    it("is called with empty passcode") {
                        fetchTwilioAccessToken(passcode: nil)

                        expect((mockAPI.invokedRequestParameters?.request as? CreateTwilioAccessTokenRequest)?.parameters.passcode).to(equal(""))
                    }
                }

                context("when passcode is 59842367125687") {
                    it("is called with 59842367125687 passcode") {
                        fetchTwilioAccessToken(passcode: "59842367125687")

                        expect((mockAPI.invokedRequestParameters?.request as? CreateTwilioAccessTokenRequest)?.parameters.passcode).to(equal("59842367125687"))
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

                context("when userIdentity is empty") {
                    context("when userDisplayName is foo") {
                        it("is called with foo identity") {
                            fetchTwilioAccessToken(userIdentity: "", userDisplayName: "foo")

                            expect((mockAPI.invokedRequestParameters?.request as? CreateTwilioAccessTokenRequest)?.parameters.userIdentity).to(equal("foo"))
                        }
                    }
                    
                    context("when userDisplayName is bar") {
                        it("is called with bar identity") {
                            fetchTwilioAccessToken(userIdentity: "", userDisplayName: "bar")

                            expect((mockAPI.invokedRequestParameters?.request as? CreateTwilioAccessTokenRequest)?.parameters.userIdentity).to(equal("bar"))
                        }
                    }
                }
                
                context("when userIdentity is foo") {
                    it("is called with foo identity") {
                        fetchTwilioAccessToken(userIdentity: "foo")

                        expect((mockAPI.invokedRequestParameters?.request as? CreateTwilioAccessTokenRequest)?.parameters.userIdentity).to(equal("foo"))
                    }
                }

                context("when result is success") {
                    context("when roomType is nil") {
                        it("does not update remoteConfigStore") {
                            fetchTwilioAccessToken(apiResult: .success(CreateTwilioAccessTokenResponse.stub(roomType: nil)))

                            expect(mockRemoteConfigStore.invokedRoomTypeSetter).to(beFalse())
                        }
                    }

                    context("when roomType is peerToPeer") {
                        it("updates remoteConfigStore") {
                            fetchTwilioAccessToken(apiResult: .success(CreateTwilioAccessTokenResponse.stub(roomType: .peerToPeer)))

                            expect(mockRemoteConfigStore.invokedRoomTypeSetterCount).to(equal(1))
                            expect(mockRemoteConfigStore.invokedRoomType).to(equal(.peerToPeer))
                        }
                    }
                    
                    context("when token is foo") {
                        it("calls completion with foo token") {
                            fetchTwilioAccessToken(apiResult: .success(CreateTwilioAccessTokenResponse.stub(token: "foo")))
                            
                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters!.result).to(equal(.success("foo")))
                        }
                    }
                    
                    context("when token is bar") {
                        it("calls completion with bar token") {
                            fetchTwilioAccessToken(apiResult: .success(CreateTwilioAccessTokenResponse.stub(token: "bar")))
                            
                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters!.result).to(equal(.success("bar")))
                        }
                    }
                }

                context("when result is failure") {
                    context("when error is passcodeExpired") {
                        it("calls completion with passcodeExpired error") {
                            fetchTwilioAccessToken(apiResult: .failure(.passcodeExpired))
                            
                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters!.result).to(equal(.failure(.passcodeExpired)))
                        }
                    }

                    context("when error is passcodeIncorrect") {
                        it("calls completion with passcodeIncorrect error") {
                            fetchTwilioAccessToken(apiResult: .failure(.passcodeIncorrect))
                            
                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters!.result).to(equal(.failure(.passcodeIncorrect)))
                        }
                    }
                }
            }
        }
    }
}
