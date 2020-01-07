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

import Fabric
import Crashlytics

protocol CrashReportStoreWriting: LaunchStore {
    func crash()
}

class CrashReportStore: NSObject, CrashReportStoreWriting {
    static let shared: CrashReportStoreWriting = CrashReportStore(appInfoStore: AppInfoStoreFactory().makeAppInfoStore())
    private let appInfoStore: AppInfoStoreReading
    private var crashlytics: Crashlytics?
    
    init(appInfoStore: AppInfoStoreReading) {
        self.appInfoStore = appInfoStore
    }
    
    func start() {
        guard appInfoStore.appInfo.target == .videoInternal else { return }
        
        // https://firebase.googleblog.com/2019/03/crashlytics-versions.html
        #if !DEBUG
        Fabric.with([Crashlytics.self])
        crashlytics = Crashlytics.sharedInstance()
        #endif
    }
    
    func crash() {
        crashlytics?.crash()
    }
}
