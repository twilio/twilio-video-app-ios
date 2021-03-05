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

class MockNotificationCenter: NotificationCenterProtocol {

    var invokedAddObserverForName = false
    var invokedAddObserverForNameCount = 0
    var invokedAddObserverForNameParameters: (name: NSNotification.Name?, obj: Any?, queue: OperationQueue?)?
    var invokedAddObserverForNameParametersList = [(name: NSNotification.Name?, obj: Any?, queue: OperationQueue?)]()
    var stubbedAddObserverForNameBlockResult: (Notification, Void)?
    var stubbedAddObserverForNameResult: NSObjectProtocol!

    func addObserver(
        forName name: NSNotification.Name?,
        object obj: Any?,
        queue: OperationQueue?,
        using block: @escaping (Notification) -> Void
    ) -> NSObjectProtocol {
        invokedAddObserverForName = true
        invokedAddObserverForNameCount += 1
        invokedAddObserverForNameParameters = (name, obj, queue)
        invokedAddObserverForNameParametersList.append((name, obj, queue))
        if let result = stubbedAddObserverForNameBlockResult {
            block(result.0)
        }
        return stubbedAddObserverForNameResult
    }

    var invokedAddObserverSelector = false
    var invokedAddObserverSelectorCount = 0
    var invokedAddObserverSelectorParameters: (observer: Any, aSelector: Selector, aName: NSNotification.Name?, anObject: Any?)?
    var invokedAddObserverSelectorParametersList = [(observer: Any, aSelector: Selector, aName: NSNotification.Name?, anObject: Any?)]()

    func addObserver(
        _ observer: Any,
        selector aSelector: Selector,
        name aName: NSNotification.Name?,
        object anObject: Any?
    ) {
        invokedAddObserverSelector = true
        invokedAddObserverSelectorCount += 1
        invokedAddObserverSelectorParameters = (observer, aSelector, aName, anObject)
        invokedAddObserverSelectorParametersList.append((observer, aSelector, aName, anObject))
    }

    var invokedPost = false
    var invokedPostCount = 0
    var invokedPostParameters: (aName: NSNotification.Name, anObject: Any?)?
    var invokedPostParametersList = [(aName: NSNotification.Name, anObject: Any?)]()

    func post(name aName: NSNotification.Name, object anObject: Any?) {
        invokedPost = true
        invokedPostCount += 1
        invokedPostParameters = (aName, anObject)
        invokedPostParametersList.append((aName, anObject))
    }
}
