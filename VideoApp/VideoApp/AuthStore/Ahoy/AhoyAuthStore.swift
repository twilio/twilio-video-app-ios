//
//  AhoyAuthStore.swift
//  VideoApp
//
//  Created by Tim Rozum on 10/22/19.
//  Copyright © 2019 Twilio, Inc. All rights reserved.
//

import Foundation

class AhoyAuthStore: NSObject, AuthStoreEverything {
    var delegate: AuthStoreWritingDelegate? {
        get { return firebaseAuthStore.delegate }
        set { firebaseAuthStore.delegate = newValue }
    }
    var isSignedIn: Bool { return firebaseAuthStore.isSignedIn }
    var userDisplayName: String { return firebaseAuthStore.userDisplayName }
    private let firebaseAuthStore: FirebaseAuthStoreWriting
    private let api: TwilioVideoAppAPIProtocol
    private let appSettingsStore: AppSettingsStoreReading
    
    init(
        api: TwilioVideoAppAPIProtocol,
        appSettingsStore: AppSettingsStoreReading,
        firebaseAuthStore: FirebaseAuthStoreWriting
    ) {
        self.firebaseAuthStore = firebaseAuthStore
        self.api = api
        self.appSettingsStore = appSettingsStore
    }
    
    func start() {
        firebaseAuthStore.start()
    }
    
    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        firebaseAuthStore.signIn(email: email, password: password, completion: completion)
    }
    
    func signOut() {
        firebaseAuthStore.signOut()
    }

    func openURL(_ url: URL, sourceApplication: String?, annotation: Any?) -> Bool {
        return firebaseAuthStore.openURL(url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func fetchTwilioAccessToken(roomName: String, completion: @escaping (String?, Error?) -> Void) {
        firebaseAuthStore.fetchAccessToken { [weak self] accessToken, error in
            guard let self = self, let accessToken = accessToken else { completion(nil, error); return }
            
            let appSettings = self.appSettingsStore.appSettings
            
            self.api.retrieveAccessToken(
                forIdentity: self.userDisplayName,
                roomName: roomName,
                authToken: accessToken,
                environment: appSettings.environment,
                topology: appSettings.topology
            ) { accessToken, error in
                completion(accessToken, error)
            }
        }
    }
}
