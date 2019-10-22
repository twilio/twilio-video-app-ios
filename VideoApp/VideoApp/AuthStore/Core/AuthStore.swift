//
//  AuthStore.swift
//  VideoApp
//
//  Created by Tim Rozum on 10/22/19.
//  Copyright © 2019 Twilio, Inc. All rights reserved.
//

import Foundation

@objc protocol AuthStoreWritingDelegate: AnyObject {
    func didSignIn(error: Error?, isValidEmail: Bool)
    func didSignOut()
}

@objc protocol AuthStoreWriting: AuthStoreReading {
    var delegate: AuthStoreWritingDelegate? { get set }
    func start()
    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void)
    func signOut()
    func openURL(_ url: URL, sourceApplication: String?, annotation: Any?) -> Bool
}

@objc protocol AuthStoreReading: AnyObject {
    var isSignedIn: Bool { get }
    var userDisplayName: String { get }
}

@objc protocol AuthStoreTwilioAccessTokenFetching: AnyObject {
    func fetchTwilioAccessToken(roomName: String, completion: @escaping (String?, Error?) -> Void)
}

@objc protocol AuthStoreEverything: AuthStoreWriting, AuthStoreTwilioAccessTokenFetching { }

@objc class AuthStore: NSObject {
    @objc static let shared: AuthStoreEverything = AuthStoreFactory().makeAuthStore()
}
