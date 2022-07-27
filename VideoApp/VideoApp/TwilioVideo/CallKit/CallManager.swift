//
//  Copyright (C) 2022 Twilio, Inc.
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

import CallKit
import Combine
import TwilioVideo

class CallManager: NSObject, ObservableObject {
    let connectPublisher = PassthroughSubject<Void, Never>()
    let disconnectPublisher = PassthroughSubject<Error?, Never>()

    private let controller = CXCallController()
    private let provider: CXProvider
    private let audioDevice = DefaultAudioDevice()
    private let accessTokenStore = TwilioAccessTokenStore()
    private var roomManager: RoomManager!
    private var subscriptions = Set<AnyCancellable>()

    override init() {
        let providerConfiguration = CXProviderConfiguration()
        providerConfiguration.maximumCallGroups = 1
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.supportsVideo = true
        providerConfiguration.supportedHandleTypes = [.generic]

        if let iconMaskImage = UIImage(named: "CallKitIcon") {
            providerConfiguration.iconTemplateImageData = iconMaskImage.pngData()
        }

        // TODO: Handle end call from system call screen
        
        provider = CXProvider(configuration: providerConfiguration)

        super.init()

        provider.setDelegate(self, queue: nil)

        TwilioVideoSDK.audioDevice = audioDevice
    }
    
    func configure(roomManager: RoomManager) {
        self.roomManager = roomManager
        
        roomManager.roomConnectPublisher
            .sink { [weak self] in
                guard let uuid = roomManager.room?.uuid else { return }
                
                self?.provider.reportOutgoingCall(with: uuid, connectedAt: nil)
                self?.connectPublisher.send()
            }
            .store(in: &subscriptions)
        
        roomManager.roomDisconnectPublisher
            .sink { [ weak self] disconnectOutput in // TODO: Improve
                guard let error = disconnectOutput.error, let uuid = disconnectOutput.uuid else {
                    return
                }

                self?.provider.reportCall(with: uuid, endedAt: nil, reason: .failed)
                self?.handleError(error)
            }
            .store(in: &subscriptions)
    }
    
    func startCall(roomName: String) {
        let handle = CXHandle(type: .generic, value: roomName)
        let action = CXStartCallAction(call: UUID(), handle: handle)
        action.isVideo = true
        let transaction = CXTransaction(action: action)
        
        controller.request(transaction) { [weak self] error in
            if let error = error {
                self?.handleError(error)
            }
        }
    }
    
    func endCall() {
        guard let uuid = roomManager.room?.uuid else { return }
        
        let action = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: action)
        
        controller.request(transaction) { [weak self] error in
            if let error = error {
                self?.handleError(error)
            }
        }
    }
    
    func updateMute(isMuted: Bool) {
        if let uuid = roomManager.room?.uuid {
            /// A call is in progress so go through CallKit
            let muteAction = CXSetMutedCallAction(call: uuid, muted: isMuted)
            let transaction = CXTransaction(action: muteAction)

            controller.request(transaction) { error in
                if let error = error {
                    print("Mute error: \(error)") // TODO: Do something with this error?
                }
            }
        } else {
            /// Not connected so bypass CallKit
            roomManager.localParticipant.isMicOn = !isMuted
        }
    }
    
    private func cleanUp() {
        audioDevice.isEnabled = false
        roomManager.disconnect()
        roomManager.localParticipant.isMicOn = false // TODO: local participant environment object?
        roomManager.localParticipant.isCameraOn = false
    }
    
    private func handleError(_ error: Error) {
        cleanUp()
        disconnectPublisher.send(error)
    }
}

extension CallManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        handleError(VideoAppError.callKitReset)
    }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        action.fulfill()
        provider.reportOutgoingCall(with: action.callUUID, startedConnectingAt: nil)
        
        // TODO: Fix this
        accessTokenStore.fetchTwilioAccessTokenOld(roomName: action.handle.value) { [weak self] result in
            switch result {
            case let .success(token):
                self?.roomManager.connect(roomName: action.handle.value, accessToken: token, uuid: action.callUUID)
            case let .failure(error):
                provider.reportCall(with: action.callUUID, endedAt: nil, reason: .failed)
                self?.handleError(error)
            }
        }
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        guard roomManager.room?.uuid == action.callUUID else {
            action.fail()
            return
        }
        
        cleanUp()
        disconnectPublisher.send(nil)
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        guard action.callUUID == roomManager.room?.uuid else {
            action.fail()
            return
        }
        
        roomManager.localParticipant.handleHold(isOnHold: action.isOnHold)
        action.fulfill()

        print("set held call action")
        
        // TODO: Make sure recent call deep link works
    }

    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        roomManager.localParticipant.isMicOn = !action.isMuted
        action.fulfill()
    }

    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        audioDevice.isEnabled = true
    }

    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        audioDevice.isEnabled = false // TODO: Not sure this is needed
    }
}
