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
