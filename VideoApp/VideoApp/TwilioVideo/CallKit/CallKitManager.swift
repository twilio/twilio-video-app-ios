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

class CallKitManager: NSObject {
    static let shared = CallKitManager()
    var roomManager: RoomManager! {
        didSet {
            roomManager.roomConnectPublisher
                .sink { [weak self] in self?.handleConnect() }
                .store(in: &subscriptions)
        }
    }
    private let accessTokenStore = TwilioAccessTokenStore()
    private let provider: CXProvider
    private let controller = CXCallController()
    private var subscriptions = Set<AnyCancellable>()
    private let audioDevice = DefaultAudioDevice()

    static let providerConfiguration: CXProviderConfiguration = {
        let providerConfiguration = CXProviderConfiguration()

        // Prevents multiple calls from being grouped.
        providerConfiguration.maximumCallGroups = 1
        providerConfiguration.maximumCallsPerCallGroup = 1
        
        providerConfiguration.supportsVideo = true
        providerConfiguration.supportedHandleTypes = [.generic]

        return providerConfiguration
    }()
    
    override init() {
        provider = CXProvider(configuration: type(of: self).providerConfiguration)

        super.init()

        provider.setDelegate(self, queue: nil)
    }
    
    func setupAudio() {
        TwilioVideoSDK.audioDevice = audioDevice
    }
    
    func startCall(roomName: String) {
        let handle = CXHandle(type: .generic, value: roomName)
        let uuid = UUID()
        print("new UUID: \(uuid)")
        let action = CXStartCallAction(call: uuid, handle: handle)
        action.isVideo = true
        let transaction = CXTransaction(action: action)
        
        controller.request(transaction) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Start call action transaction request successful")
            }
        }
    }
    
    func endCall(uuid: UUID) {
        let action = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: action)
        
        controller.request(transaction) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("End call action transaction request successful")
            }
        }
    }
    
    private func handleConnect() {
        guard let uuid = roomManager.room?.uuid else { return }
        
        provider.reportOutgoingCall(with: uuid, connectedAt: nil)
    }
}

extension CallKitManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        print("Provider did reset")
        
        audioDevice.isEnabled = false

//        stopAudio()
//
//        /*
//         End any ongoing calls if the provider resets, and remove them from the app's list of calls
//         because they are no longer valid.
//         */
//        for call in callManager.calls {
//            call.endSpeakerboxCall()
//        }
//
//        // Remove all calls from the app's list of calls.
//        callManager.removeAllCalls()
    }


    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        // Configure audio session?

        // Verify we wanted to connect to this room? Store call detail state somewhere?
        
        accessTokenStore.fetchTwilioAccessTokenOld(roomName: action.handle.value) { [weak self] result in
            switch result {
            case let .success(token):
                self?.roomManager.connect(roomName: action.handle.value, accessToken: token, uuid: action.callUUID)
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
        
        action.fulfill()
        provider.reportOutgoingCall(with: action.callUUID, startedConnectingAt: nil)

        
        
//        // Create and configure an instance of SpeakerboxCall to represent the new outgoing call.
//        let call = SpeakerboxCall(uuid: action.callUUID, isOutgoing: true)
//        call.handle = action.handle.value
//
//        /*
//         Configure the audio session but do not start call audio here.
//         Call audio should not be started until the audio session is activated by the system,
//         after having its priority elevated.
//         */
//        configureAudioSession()
//
//        /*
//         Set callbacks for significant events in the call's lifecycle,
//         so that the CXProvider can be updated to reflect the updated state.
//         */
//        call.hasStartedConnectingDidChange = { [weak self] in
//            self?.provider.reportOutgoingCall(with: call.uuid, startedConnectingAt: call.connectingDate)
//        }
//        call.hasConnectedDidChange = { [weak self] in
//            self?.provider.reportOutgoingCall(with: call.uuid, connectedAt: call.connectDate)
//        }
//
//        // Trigger the call to be started via the underlying network service.
//        call.startSpeakerboxCall { success in
//            if success {
//                // Signal to the system that the action was successfully performed.
//                action.fulfill()
//
//                // Add the new outgoing call to the app's list of calls.
//                self.callManager.addCall(call)
//            } else {
//                // Signal to the system that the action was unable to be performed.
//                action.fail()
//            }
//        }
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
       
        // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID.
//        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
//            action.fail()
//            return
//        }
//
//        /*
//         Configure the audio session but do not start call audio here.
//         Call audio should not be started until the audio session is activated by the system,
//         after having its priority elevated.
//         */
//        configureAudioSession()
//
//        // Trigger the call to be answered via the underlying network service.
//        call.answerSpeakerboxCall()
//
//        // Signal to the system that the action was successfully performed.
//        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        roomManager?.disconnect()

        // Do audio stuff?
        
        action.fulfill()

//        // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID
//        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
//            action.fail()
//            return
//        }
//
//        // Stop call audio when ending a call.
//        stopAudio()
//
//        // Trigger the call to be ended via the underlying network service.
//        call.endSpeakerboxCall()
//
//        // Signal to the system that the action was successfully performed.
//        action.fulfill()
//
//        // Remove the ended call from the app's list of calls.
//        callManager.removeCall(call)
    }

    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
//        // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID
//        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
//            action.fail()
//            return
//        }
//
//        // Update the SpeakerboxCall's underlying hold state.
//        call.isOnHold = action.isOnHold
//
//        // Stop or start audio in response to holding or unholding the call.
//        if call.isOnHold {
//            stopAudio()
//        } else {
//            startAudio()
//        }
//
//        // Signal to the system that the action has been successfully performed.
//        action.fulfill()
    }

    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        print("Timed out", #function)

        // React to the action timeout if necessary, such as showing an error UI.
    }

    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        audioDevice.isEnabled = true
        
        /*
         Start call audio media, now that the audio session is activated,
         after having its priority elevated.
         */
//        startAudio()
    }

    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        audioDevice.isEnabled = false

        /*
         Restart any non-call related audio now that the app's audio session is deactivated,
         after having its priority restored to normal.
         */
    }
}
