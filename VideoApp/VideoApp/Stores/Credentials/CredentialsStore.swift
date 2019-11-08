//
//  CredentialsStore.swift
//  VideoApp
//
//  Created by Tim Rozum on 10/18/19.
//  Copyright © 2019 Twilio, Inc. All rights reserved.
//

import Foundation

class CredentialsStore {
    private let bundle = Bundle.main
    private let jsonDecoder = JSONDecoder()
    
    var credentials: Credentials {
        let url = bundle.url(forResource: gCurrentAppEnvironment.credentialsResource, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let credentials = try! jsonDecoder.decode(Credentials.self, from: data)
        
        return credentials
    }
}

private extension VideoAppEnvironment {
    var credentialsResource: String {
        switch self {
        case .twilio: return "TwilioCredentials"
        case .internal: return "InternalCredentials"
        case .community: return "CommunityCredentials"
        @unknown default: fatalError()
        }
    }
}
