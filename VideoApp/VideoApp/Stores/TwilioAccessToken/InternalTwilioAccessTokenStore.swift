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

class InternalTwilioAccessTokenStore: TwilioAccessTokenStoreReading {
    private let api: APIRequesting
    private let appSettingsStore: AppSettingsStoreWriting
    private let authStore: AuthStoreWriting

    init(
        api: APIRequesting,
        appSettingsStore: AppSettingsStoreWriting,
        authStore: AuthStoreWriting
    ) {
        self.api = api
        self.appSettingsStore = appSettingsStore
        self.authStore = authStore
    }
    
    func fetchTwilioAccessToken(roomName: String, completion: @escaping (Result<String, APIError>) -> Void) {
        authStore.refreshIDToken { [weak self] in
            guard let self = self else { return }

            let request = InternalCreateTwilioAccessTokenRequest(
                identity: self.appSettingsStore.userIdentity.nilIfEmpty ?? self.authStore.userDisplayName,
                roomName: roomName,
                topology: .init(topology: self.appSettingsStore.topology)
            )
            
            self.api.request(request, completion: completion)
        }
    }
}

private extension InternalCreateTwilioAccessTokenRequest.Parameters.Topology {
    init(topology: Topology) {
        switch topology {
        case .group: self = .group
        case .peerToPeer: self = .peerToPeer
        }
    }
}
