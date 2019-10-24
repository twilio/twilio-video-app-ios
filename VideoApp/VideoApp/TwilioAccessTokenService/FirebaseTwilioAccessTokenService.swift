//
//  FirebaseTwilioAccessTokenService.swift
//  VideoApp
//
//  Created by Tim Rozum on 10/16/19.
//  Copyright © 2019 Twilio, Inc. All rights reserved.
//

import Foundation

protocol TwilioVideoAppAPIProtocol {
    func retrieveAccessToken(
        forIdentity identity: String,
        roomName: String,
        authToken: String,
        environment: TwilioVideoAppAPIEnvironment,
        topology: TwilioVideoAppAPITopology,
        completionBlock: @escaping (String?, Error?) -> Void
    )
}

extension TwilioVideoAppAPI: TwilioVideoAppAPIProtocol { }

class FirebaseTwilioAccessTokenService: TwilioAccessTokenService {
    private let api: TwilioVideoAppAPIProtocol
    private let appSettingsStore: AppSettingsStoreReading
    private let firebaseAuthManager: FirebaseAuthManagerProtocol
    
    init(
        api: TwilioVideoAppAPIProtocol,
        appSettingsStore: AppSettingsStoreReading,
        firebaseAuthManager: FirebaseAuthManagerProtocol
    ) {
        self.api = api
        self.appSettingsStore = appSettingsStore
        self.firebaseAuthManager = firebaseAuthManager
    }
    
    func fetchAccessToken(roomName: String, completion: @escaping (String?, Error?) -> Void) {
        firebaseAuthManager.getIDToken { [weak self] token, error in
            guard let self = self, let token = token else { completion(nil, error); return }
            
            let appSettings = self.appSettingsStore.appSettings
            
            self.api.retrieveAccessToken(
                forIdentity: self.firebaseAuthManager.currentUserDisplayName,
                roomName: roomName,
                authToken: token,
                environment: appSettings.environment,
                topology: appSettings.topology
            ) { accessToken, error in
                completion(accessToken, error)
            }
        }
    }
}
