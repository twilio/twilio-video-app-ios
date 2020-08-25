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

class MockDispatchQueue: DispatchQueueProtocol {

    var invokedAsyncGroup = false
    var invokedAsyncGroupCount = 0
    var invokedAsyncGroupParameters: (group: DispatchGroup?, qos: DispatchQoS, flags: DispatchWorkItemFlags)?
    var invokedAsyncGroupParametersList = [(group: DispatchGroup?, qos: DispatchQoS, flags: DispatchWorkItemFlags)]()
    var shouldInvokeAsyncGroupWork = false

    func async(
        group: DispatchGroup?,
        qos: DispatchQoS,
        flags: DispatchWorkItemFlags,
        execute work: @escaping @convention(block) () -> Void
    ) {
        invokedAsyncGroup = true
        invokedAsyncGroupCount += 1
        invokedAsyncGroupParameters = (group, qos, flags)
        invokedAsyncGroupParametersList.append((group, qos, flags))
        if shouldInvokeAsyncGroupWork {
            work()
        }
    }

    var invokedAsync = false
    var invokedAsyncCount = 0
    var shouldInvokeAsyncWork = false

    func async(execute work: @escaping @convention(block) () -> Void) {
        invokedAsync = true
        invokedAsyncCount += 1
        if shouldInvokeAsyncWork {
            work()
        }
    }
}
