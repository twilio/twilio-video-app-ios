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

@testable import VideoApp

class MockRemoteConfigStore: RemoteConfigStoreWriting {

    var invokedRoomTypeSetter = false
    var invokedRoomTypeSetterCount = 0
    var invokedRoomType: CreateTwilioAccessTokenResponse.RoomType?
    var invokedRoomTypeList = [CreateTwilioAccessTokenResponse.RoomType]()
    var invokedRoomTypeGetter = false
    var invokedRoomTypeGetterCount = 0
    var stubbedRoomType: CreateTwilioAccessTokenResponse.RoomType!

    var roomType: CreateTwilioAccessTokenResponse.RoomType {
        set {
            invokedRoomTypeSetter = true
            invokedRoomTypeSetterCount += 1
            invokedRoomType = newValue
            invokedRoomTypeList.append(newValue)
        }
        get {
            invokedRoomTypeGetter = true
            invokedRoomTypeGetterCount += 1
            return stubbedRoomType
        }
    }
}
