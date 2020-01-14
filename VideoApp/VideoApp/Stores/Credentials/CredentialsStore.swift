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

class CredentialsStore {
    private let bundle = Bundle.main
    private let jsonDecoder = JSONDecoder()
    private let appInfoStore: AppInfoStoreReading = AppInfoStoreFactory().makeAppInfoStore()

    var credentials: Credentials {
        let url = bundle.url(forResource: appInfoStore.appInfo.target.credentialsResource, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let credentials = try! jsonDecoder.decode(Credentials.self, from: data)

        return credentials
    }
}

private extension AppInfo.Target {
    var credentialsResource: String {
        switch self {
        case .videoTwilio: return "TwilioCredentials"
        case .videoInternal: return "InternalCredentials"
        case .videoCommunity: return "CommunityCredentials"
        }
    }
}
