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

import Foundation

class CommunityTwilioAccessTokenStore: TwilioAccessTokenStoreReading {
    private let api: APIRequesting
    private let appSettingsStore: AppSettingsStoreWriting
    private let authStore: AuthStoreReading

    init(
        api: APIRequesting,
        appSettingsStore: AppSettingsStoreWriting,
        authStore: AuthStoreReading
    ) {
        self.api = api
        self.appSettingsStore = appSettingsStore
        self.authStore = authStore
    }

    func fetchTwilioAccessToken(roomName: String, completion: @escaping (Result<String, APIError>) -> Void) {
        let request = CommunityCreateTwilioAccessTokenRequest(
            passcode: authStore.passcode ?? "",
            userIdentity: appSettingsStore.userIdentity,
            roomName: roomName
        )
        
        api.request(request) { completion($0.map { $0.token }) }
    }
}
