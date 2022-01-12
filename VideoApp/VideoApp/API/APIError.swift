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

enum APIError: Error, Equatable {
    case decodeError
    case message(message: String)
    case notConnectedToInternet
    case passcodeExpired
    case passcodeIncorrect

    init(message: APIErrorResponse.Error.Message) {
        switch message {
        case .passcodeExpired: self = .passcodeExpired
        case .passcodeIncorrect: self = .passcodeIncorrect
        }
    }

    var localizedDescription: String {
        switch self {
        case .decodeError: return "Decode error."
        case let .message(message): return message
        case .notConnectedToInternet: return "The Internet connection appears to be offline."
        case .passcodeExpired: return "Passcode expired. Please sign in with a new passcode."
        case .passcodeIncorrect: return "Passcode incorrect."
        }
    }
}
