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

protocol CredentialsStoreReading: AnyObject {
    var credentials: Credentials { get }
}

class CredentialsStore: CredentialsStoreReading {
    var credentials: Credentials {
        let url = bundle.url(forResource: "InternalCredentials", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return try! jsonDecoder.decode(Credentials.self, from: data)
    }
    private let bundle: BundleProtocol
    private let jsonDecoder: JSONDecoderProtocol
    private let appInfoStore: AppInfoStoreReading

    init(bundle: BundleProtocol, jsonDecoder: JSONDecoderProtocol, appInfoStore: AppInfoStoreReading) {
        self.bundle = bundle
        self.jsonDecoder = jsonDecoder
        self.appInfoStore = appInfoStore
    }
}
