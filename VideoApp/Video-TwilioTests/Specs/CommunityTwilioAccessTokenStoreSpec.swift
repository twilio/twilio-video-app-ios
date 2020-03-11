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

class CommunityTwilioAccessTokenStoreSpec: QuickSpec {
    override func spec() {
        var sut: CommunityTwilioAccessTokenStore!
        var mockAPI: MockAPI!
        var mockAppSettingsStore: MockAppSettingsStore!
        var mockAuthStore: MockAuthStore!

        beforeEach {
            mockAPI = MockAPI()
            mockAppSettingsStore = MockAppSettingsStore()
            mockAuthStore = MockAuthStore()
            sut = CommunityTwilioAccessTokenStore(
                api: mockAPI,
                appSettingsStore: mockAppSettingsStore,
                authStore: mockAuthStore
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
                userIdentity: String = "",
                roomName: String = "",
                apiResult: Result<Any, APIError> = .success(CommunityCreateTwilioAccessTokenResponse.stub())
            ) {
                mockAuthStore.stubbedPasscode = passcode
                mockAppSettingsStore.stubbedUserIdentity = userIdentity
                mockAPI.stubbedRequestCompletionResult = apiResult
                sut.fetchTwilioAccessToken(roomName: roomName) { result in
                    invokedCompletionCount += 1
                    invokedCompletionParameters = (result, ())
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
                        
                        expect((mockAPI.invokedRequestParameters?.request as? CommunityCreateTwilioAccessTokenRequest)?.parameters.passcode).to(equal(""))
                    }
                }

                context("when passcode is foo") {
                    it("is called with foo passcode") {
                        fetchTwilioAccessToken(passcode: "foo")
                        
                        expect((mockAPI.invokedRequestParameters?.request as? CommunityCreateTwilioAccessTokenRequest)?.parameters.passcode).to(equal("foo"))
                    }
                }

                context("when userIdentity is foo") {
                    it("is called with foo userIdentity") {
                        fetchTwilioAccessToken(userIdentity: "foo")
                        
                        expect((mockAPI.invokedRequestParameters?.request as? CommunityCreateTwilioAccessTokenRequest)?.parameters.userIdentity).to(equal("foo"))
                    }
                }

                context("when userIdentity is bar") {
                    it("is called with bar userIdentity") {
                        fetchTwilioAccessToken(userIdentity: "bar")
                        
                        expect((mockAPI.invokedRequestParameters?.request as? CommunityCreateTwilioAccessTokenRequest)?.parameters.userIdentity).to(equal("bar"))
                    }
                }

                context("when roomName is foo") {
                    it("is called with foo roomName") {
                        fetchTwilioAccessToken(roomName: "foo")
                        
                        expect((mockAPI.invokedRequestParameters?.request as? CommunityCreateTwilioAccessTokenRequest)?.parameters.roomName).to(equal("foo"))
                    }
                }

                context("when roomName is bar") {
                    it("is called with bar roomName") {
                        fetchTwilioAccessToken(roomName: "bar")
                        
                        expect((mockAPI.invokedRequestParameters?.request as? CommunityCreateTwilioAccessTokenRequest)?.parameters.roomName).to(equal("bar"))
                    }
                }
                
                context("when result is success") {
                    context("when token is foo") {
                        it("calls completion with foo token") {
                            fetchTwilioAccessToken(apiResult: .success(CommunityCreateTwilioAccessTokenResponse.stub(token: "foo")))
                            
                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters?.result).to(equal(.success("foo")))
                        }
                    }
                    
                    context("when token is bar") {
                        it("calls completion with bar token") {
                            fetchTwilioAccessToken(apiResult: .success(CommunityCreateTwilioAccessTokenResponse.stub(token: "bar")))
                            
                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters?.result).to(equal(.success("bar")))
                        }
                    }
                }

                context("when result is failure") {
                    context("when error is passcodeExpired") {
                        it("calls completion with passcodeExpired error") {
                            fetchTwilioAccessToken(apiResult: .failure(.passcodeExpired))
                            
                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters?.result).to(equal(.failure(.passcodeExpired)))
                        }
                    }

                    context("when error is notConnectedToInternet") {
                        it("calls completion with notConnectedToInternet error") {
                            fetchTwilioAccessToken(apiResult: .failure(.notConnectedToInternet))
                            
                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters?.result).to(equal(.failure(.notConnectedToInternet)))
                        }
                    }
                }
            }
        }
    }
}
