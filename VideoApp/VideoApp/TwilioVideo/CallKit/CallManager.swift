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

/// This is the interface the UI should use to start or end a video call.
///
/// CallKit is used to integrate the Twilio video call with the system call interface. Most importantly,
/// this ensures that the app will not be suspended when it is running in the background, even if
/// the app is not playing or capturing audio. CallKit also increases the audio priority so the app
/// is not interrupted by media apps. Interruptions from calling apps are also handled better,
/// allowing the video call to be placed on hold instead of dropping the video call with no warning
/// to the user.
class CallManager: NSObject, ObservableObject {
    let connectPublisher = PassthroughSubject<Void, Never>()
    let disconnectPublisher = PassthroughSubject<Error?, Never>()
    
    /// CallKit
    private let controller = CXCallController(queue: .main)
    private let provider: CXProvider
    
    /// Twilio video
    private let audioDevice = DefaultAudioDevice()
    private let accessTokenStore = TwilioAccessTokenStore()
    private var roomManager: RoomManager!
    private var localParticipant: LocalParticipantManager { roomManager.localParticipant }

    private var callUUID: UUID?
    private var subscriptions = Set<AnyCancellable>()

    override init() {
        let configuration = CXProviderConfiguration()
        
        /// This app only supports 1 video call at a time
        configuration.maximumCallGroups = 1
        configuration.maximumCallsPerCallGroup = 1

        configuration.supportsVideo = true
        configuration.supportedHandleTypes = [.generic]

        if let icon = UIImage(named: "CallKitIcon") {
            configuration.iconTemplateImageData = icon.pngData()
        }
        
        provider = CXProvider(configuration: configuration)

        super.init()

        provider.setDelegate(self, queue: nil)

        TwilioVideoSDK.audioDevice = audioDevice
    }
    
    func configure(roomManager: RoomManager) {
        self.roomManager = roomManager
        
        roomManager.roomConnectPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                
                self.provider.reportOutgoingCall(with: self.callUUID!, connectedAt: nil)
                self.connectPublisher.send()
            }
            .store(in: &subscriptions)
        
        roomManager.roomDisconnectPublisher
            .sink { [ weak self] error in
                guard let self = self, let error = error else {
                    /// Only have to handle the error case for this
                    return
                }
                
                self.provider.reportCall(with: self.callUUID!, endedAt: nil, reason: .failed)
                self.handleError(error)
            }
            .store(in: &subscriptions)
    }
    
    func connect(roomName: String) {
        let handle = CXHandle(type: .generic, value: roomName)

        let callUUID = UUID()
        let startCallAction = CXStartCallAction(call: callUUID, handle: handle)
        startCallAction.isVideo = true
        self.callUUID = callUUID

        let transaction = CXTransaction(action: startCallAction)
                
        controller.request(transaction) { [weak self] error in
            if let error = error {
                self?.handleError(error)
            }
        }
    }

    func disconnect() {
        let endCallAction = CXEndCallAction(call: callUUID!)
        let transaction = CXTransaction(action: endCallAction)
        
        controller.request(transaction) { [weak self] error in
            if let error = error {
                self?.handleError(error)
            }
        }
    }

    func setMute(isMuted: Bool) {
        if let callUUID = callUUID {
            /// A call is in progress so control mute via CallKit. This will ensure that the system
            /// call screen displays the correct mute status.
            let setMutedCallAction = CXSetMutedCallAction(call: callUUID, muted: isMuted)
            let transaction = CXTransaction(action: setMutedCallAction)

            controller.request(transaction) { error in
                if let error = error {
                    print("Error requesting mute: \(error)")
                }
            }
        } else {
            /// Don't use CallKit when setting up media before joining a call
            localParticipant.isMicOn = !isMuted
        }
    }
    
    private func cleanUp() {
        callUUID = nil
        audioDevice.isEnabled = false
        roomManager.disconnect()
        localParticipant.isMicOn = false
        localParticipant.isCameraOn = false
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

        accessTokenStore.fetchTwilioAccessToken(roomName: action.handle.value) { [weak self] result in
            switch result {
            case let .success(token):
                /// Connect to the Twilio video room
                self?.roomManager.connect(roomName: action.handle.value, accessToken: token, uuid: action.callUUID)
            case let .failure(error):
                provider.reportCall(with: action.callUUID, endedAt: nil, reason: .failed)
                self?.handleError(error)
            }
        }
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        guard action.callUUID == callUUID else {
            action.fail()
            return
        }
        
        cleanUp()
        disconnectPublisher.send(nil)
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        guard action.callUUID == callUUID else {
            action.fail()
            return
        }
        
        localParticipant.setHold(isOnHold: action.isOnHold)
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        localParticipant.isMicOn = !action.isMuted
        action.fulfill()
    }

    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        audioDevice.isEnabled = true
    }

    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        audioDevice.isEnabled = false
    }
}
