//
//  TwilioVideoAppAPI.h
//  VideoApp
//
//  Created by Ryan Payne on 10/16/18.
//  Copyright © 2018 Twilio, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Infrastructure Environment
typedef NSString *const TwilioVideoAppAPIEnvironment NS_STRING_ENUM;
FOUNDATION_EXPORT TwilioVideoAppAPIEnvironment kTwilioVideoAppAPIEnvironmentProduction;
FOUNDATION_EXPORT TwilioVideoAppAPIEnvironment kTwilioVideoAppAPIEnvironmentStaging;
FOUNDATION_EXPORT TwilioVideoAppAPIEnvironment kTwilioVideoAppAPIEnvironmentDevelopment;

// App Environment
typedef NSString *const TwilioVideoAppAPIAppEnvironment NS_STRING_ENUM;
FOUNDATION_EXPORT TwilioVideoAppAPIAppEnvironment kTwilioVideoAppAPIAppEnvironmentTwilio;
FOUNDATION_EXPORT TwilioVideoAppAPIAppEnvironment kTwilioVideoAppAPIAppEnvironmentInternal;
FOUNDATION_EXPORT TwilioVideoAppAPIAppEnvironment kTwilioVideoAppAPIAppAppEnvironmentCommunity;

// Topology
typedef NSString *const TwilioVideoAppAPITopology NS_STRING_ENUM;
FOUNDATION_EXPORT TwilioVideoAppAPITopology kTwilioVideoAppAPITopologyP2P;
FOUNDATION_EXPORT TwilioVideoAppAPITopology kTwilioVideoAppAPITopologyGroup;

@interface TwilioVideoAppAPI : NSObject

- (void)retrieveAccessTokenForIdentity:(NSString *)identity
                              roomName:(NSString *)roomName
                             authToken:(NSString *)authToken
                           environment:(TwilioVideoAppAPIEnvironment)environment
                              topology:(TwilioVideoAppAPITopology)topology
                       completionBlock:(void(^)(NSString * _Nullable accessToken, NSError * _Nullable error))completionBlock;

@end

NS_ASSUME_NONNULL_END
