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

import TwilioVideo

protocol VideoStoreWriting: LaunchStore, WindowSceneObserving { }

class VideoStore: VideoStoreWriting {
    static let shared: VideoStoreWriting = VideoStore(
        appSettingsStore: AppSettingsStore.shared,
        environmentVariableStore: EnvironmentVariableStore(),
        notificationCenter: NotificationCenter.default
    )
    private let appSettingsStore: AppSettingsStoreWriting
    private let environmentVariableStore: EnvironmentVariableStoreWriting
    private let notificationCenter: NotificationCenterProtocol
        
    init(
        appSettingsStore: AppSettingsStoreWriting,
        environmentVariableStore: EnvironmentVariableStoreWriting,
        notificationCenter: NotificationCenterProtocol
    ) {
        self.appSettingsStore = appSettingsStore
        self.environmentVariableStore = environmentVariableStore
        self.notificationCenter = notificationCenter
    }
    
    func start() {
        configure()
        
        notificationCenter.addObserver(forName: .appSettingDidChange, object: nil, queue: nil) { [weak self] _ in
            self?.configure()
        }
    }
    
    @available(iOS 13, *)
    func interfaceOrientationDidChange(windowScene: UIWindowScene) {
        UserInterfaceTracker.sceneInterfaceOrientationDidChange(windowScene)
    }

    private func configure() {
        TwilioVideoSDK.setLogLevel(.init(sdkLogLevel: appSettingsStore.coreSDKLogLevel), module: .core)
        TwilioVideoSDK.setLogLevel(.init(sdkLogLevel: appSettingsStore.platformSDKLogLevel), module: .platform)
        TwilioVideoSDK.setLogLevel(.init(sdkLogLevel: appSettingsStore.signalingSDKLogLevel), module: .signaling)
        TwilioVideoSDK.setLogLevel(.init(sdkLogLevel: appSettingsStore.webRTCSDKLogLevel), module: .webRTC)
        environmentVariableStore.twilioEnvironment = appSettingsStore.environment
    }
}

private extension TwilioVideoSDK.LogLevel {
    init(sdkLogLevel: SDKLogLevel) {
        switch sdkLogLevel {
        case .off: self = .off
        case .fatal: self = .fatal
        case .error: self = .error
        case .warning: self = .warning
        case .info: self = .info
        case .debug: self = .debug
        case .trace: self = .trace
        case .all: self = .all
        }
    }
}
