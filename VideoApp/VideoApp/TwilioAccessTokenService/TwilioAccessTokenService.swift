//
//  TwilioAccessTokenService.swift
//  VideoApp
//
//  Created by Tim Rozum on 10/16/19.
//  Copyright © 2019 Twilio, Inc. All rights reserved.
//

import Foundation

@objc protocol TwilioAccessTokenService: AnyObject {
    func fetchAccessToken(roomName: String, completion: @escaping (String?, Error?) -> Void)
}
