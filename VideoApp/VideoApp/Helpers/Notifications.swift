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

extension Notification.Name {
    static let appSettingDidChange = Notification.Name("AppSettingDidChange")
    static let roomUpdate = Notification.Name("RoomUpdate")
    static let participantUpdate = Notification.Name("ParticipantUpdate")
    static let participantsStoreUpdate = Notification.Name("ParticipantsStoreUpdate")
    static let mainParticipantStoreUpdate = Notification.Name("MainParticipantStoreUpdate")
}

extension NotificationCenter {
    func post(name aName: NSNotification.Name, object anObject: Any?, payload: Any) {
        post(name: aName, object: anObject, userInfo: [Notification.payloadKey: payload])
    }
}

extension Notification {
    static let payloadKey = "payload"
    var payload: Any? { userInfo?[Self.payloadKey] }
}
