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

import Foundation

// Inspired by https://medium.com/better-programming/create-the-perfect-userdefaults-wrapper-using-property-wrapper-42ca76005ac8
@propertyWrapper
struct Storage<T: Codable> {
    private let key: String
    private let defaultValue: T
    private let userDefaults = UserDefaults.standard

    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            guard
                let data = userDefaults.object(forKey: key) as? Data,
                let container = try? JSONDecoder().decode(JSONContainer<T>.self, from: data)
                else {
                    return defaultValue
            }

            return container.value
        }
        set {
            let data = try? JSONEncoder().encode(JSONContainer(value: newValue))
            userDefaults.set(data, forKey: key)
        }
    }
}
