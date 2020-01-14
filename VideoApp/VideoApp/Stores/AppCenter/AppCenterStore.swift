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

import AppCenter
import AppCenterDistribute

protocol AppCenterStoreWriting: LaunchStore { }

class AppCenterStore: AppCenterStoreWriting {
    private let credentialsStore: CredentialsStoreReading
    
    init(credentialsStore: CredentialsStoreReading) {
        self.credentialsStore = credentialsStore
    }
    
    func start() {
        guard let appSecret = credentialsStore.credentials.appCenterAppSecret else { return }
        
        #if !DEBUG
        MSAppCenter.start(appSecret, withServices: [MSDistribute.self])
        #endif
    }
}
