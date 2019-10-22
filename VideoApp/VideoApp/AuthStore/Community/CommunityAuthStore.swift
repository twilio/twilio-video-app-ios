//
//  CommunityAuthStore.swift
//  VideoApp
//
//  Created by Tim Rozum on 10/22/19.
//  Copyright © 2019 Twilio, Inc. All rights reserved.
//

import Foundation

class CommunityAuthStore: AuthStoreEverything {
    weak var delegate: AuthStoreWritingDelegate?
    var isSignedIn: Bool { return true }
    var userDisplayName: String { return "Unknown" }

    func start() {

    }

    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        
    }
    
    func signOut() {

    }

    func openURL(_ url: URL, sourceApplication: String?, annotation: Any?) -> Bool {
        return false
    }

    func fetchTwilioAccessToken(roomName: String, completion: @escaping (String?, Error?) -> Void) {
        
    }
}
