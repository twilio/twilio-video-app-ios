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

class TwilioAccessTokenStore {
    private let api: APIRequesting
    private let appSettingsStore: AppSettingsStoreWriting
    private let authStore: AuthStoreWriting
    private let remoteConfigStore: RemoteConfigStoreWriting

    init(
        api: APIRequesting,
        appSettingsStore: AppSettingsStoreWriting,
        authStore: AuthStoreWriting,
        remoteConfigStore: RemoteConfigStoreWriting
    ) {
        self.api = api
        self.appSettingsStore = appSettingsStore
        self.authStore = authStore
        self.remoteConfigStore = remoteConfigStore
    }
    
    func fetchTwilioAccessToken(roomName: String) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            authStore.refreshIDToken { [weak self] in
                guard let self = self else { return }

                let request = CreateTwilioAccessTokenRequest(
                    passcode: self.authStore.passcode ?? "",
                    userIdentity: self.appSettingsStore.userIdentity.nilIfEmpty ?? self.authStore.userDisplayName,
                    createRoom: true,
                    roomName: roomName
                )
                
                self.api.request(request) { [weak self] result in
                    guard let self = self else { return }
                    
                    if let roomType = try? result.get().roomType {
                        self.remoteConfigStore.roomType = roomType
                    }
                    
                    continuation.resume(with: result.map { $0.token })
                }
            }
        }
    }
}
