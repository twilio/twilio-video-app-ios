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

class InternalTwilioAccessTokenStoreSpec: QuickSpec {
    override func spec() {
        var sut: InternalTwilioAccessTokenStore!
        var mockAPI: MockAPI!
        var mockAppSettingsStore: MockAppSettingsStore!
        var mockAuthStore: MockAuthStore!
        
        beforeEach {
            mockAPI = MockAPI()
            mockAppSettingsStore = MockAppSettingsStore()
            mockAuthStore = MockAuthStore()
            sut = InternalTwilioAccessTokenStore(
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
                roomName: String = "",
                userIdentity: String = "",
                userDisplayName: String = "",
                topology: Topology = .group,
                apiResult: Result<Any, APIError> = .success("")
            ) {
                mockAppSettingsStore.stubbedUserIdentity = userIdentity
                mockAppSettingsStore.stubbedTopology = topology
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

                context("when roomName is foo") {
                    it("is called with foo roomName") {
                        fetchTwilioAccessToken(roomName: "foo")
                        
                        expect((mockAPI.invokedRequestParameters?.request as? InternalCreateTwilioAccessTokenRequest)?.parameters.roomName).to(equal("foo"))
                    }
                }

                context("when roomName is bar") {
                    it("is called with bar roomName") {
                        fetchTwilioAccessToken(roomName: "bar")
                        
                        expect((mockAPI.invokedRequestParameters?.request as? InternalCreateTwilioAccessTokenRequest)?.parameters.roomName).to(equal("bar"))
                    }
                }

                context("when userIdentity is empty") {
                    context("when userDisplayName is foo") {
                        it("is called with foo identity") {
                            fetchTwilioAccessToken(userIdentity: "", userDisplayName: "foo")

                            expect((mockAPI.invokedRequestParameters?.request as? InternalCreateTwilioAccessTokenRequest)?.parameters.identity).to(equal("foo"))
                        }
                    }
                    
                    context("when userDisplayName is bar") {
                        it("is called with bar identity") {
                            fetchTwilioAccessToken(userIdentity: "", userDisplayName: "bar")

                            expect((mockAPI.invokedRequestParameters?.request as? InternalCreateTwilioAccessTokenRequest)?.parameters.identity).to(equal("bar"))
                        }
                    }
                }
                
                context("when userIdentity is foo") {
                    it("is called with foo identity") {
                        fetchTwilioAccessToken(userIdentity: "foo")

                        expect((mockAPI.invokedRequestParameters?.request as? InternalCreateTwilioAccessTokenRequest)?.parameters.identity).to(equal("foo"))
                    }
                }

                context("when topology is group") {
                    it("is called with group topology") {
                        fetchTwilioAccessToken(topology: .group)

                        expect((mockAPI.invokedRequestParameters?.request as? InternalCreateTwilioAccessTokenRequest)?.parameters.topology).to(equal(.group))
                    }
                }

                context("when topology is peerToPeer") {
                    it("is called with peerToPeer topology") {
                        fetchTwilioAccessToken(topology: .peerToPeer)

                        expect((mockAPI.invokedRequestParameters?.request as? InternalCreateTwilioAccessTokenRequest)?.parameters.topology).to(equal(.peerToPeer))
                    }
                }

                context("when result is success") {
                    context("when response is foo") {
                        it("calls completion with foo token") {
                            fetchTwilioAccessToken(apiResult: .success("foo"))
                            
                            expect(invokedCompletionCount).to(equal(1))
                            expect(invokedCompletionParameters?.result).to(equal(.success("foo")))
                        }
                    }
                    
                    context("when response is bar") {
                        it("calls completion with bar token") {
                            fetchTwilioAccessToken(apiResult: .success("bar"))
                            
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
