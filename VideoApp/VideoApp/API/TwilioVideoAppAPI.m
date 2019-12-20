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

#import "TwilioVideoAppAPI.h"
#import "VideoApp-Swift.h"

// Infrastructure Environment
TwilioVideoAppAPIEnvironment kTwilioVideoAppAPIEnvironmentProduction        = @"prod";
TwilioVideoAppAPIEnvironment kTwilioVideoAppAPIEnvironmentStaging           = @"stage";
TwilioVideoAppAPIEnvironment kTwilioVideoAppAPIEnvironmentDevelopment       = @"dev";

// Topology
TwilioVideoAppAPITopology kTwilioVideoAppAPITopologyP2P                     = @"peer-to-peer";
TwilioVideoAppAPITopology kTwilioVideoAppAPITopologyGroup                   = @"group";

// Route endpoints
static NSString *const kTwilioVideoAppAPITokenEndpoint                      = @"/api/v1/token";

// Parameter keys
static NSString *const kTwilioVideoAppAPIIdentityKey                        = @"identity";
static NSString *const kTwilioVideoAppAPIRoomNameKey                        = @"roomName";
static NSString *const kTwilioVideoAppAPIAppEnvironmentKey                  = @"appEnvironment";
static NSString *const kTwilioVideoAppAPITopologyKey                        = @"topology";
static NSString *const kTwilioVideoAppAPIRecordParticipantsOnConnectKey     = @"recordParticipantsOnConnect";
static NSString *const kTwilioVideoAppAPITTLKey                             = @"ttl";
static NSString *const kTwilioVideoAppAPIKeyKey                             = @"key";

// Host info
static NSString *const kTwilioVideoAppAPIHostPrefix                         = @"app.";
static NSString *const kTwilioVideoAppAPIStageQualifier                     = @"stage.";
static NSString *const kTwilioVideoAppAPIDevQualifier                       = @"dev.";
static NSString *const kTwilioVideoAppAPIHostSuffix                         = @"video.bytwilio.com";

static NSString *const kTwilioVideoAppAPIAuthorizationHeader                = @"Authorization";
static NSString *const kTwilioVideoAppAPIErrorDomain                        = @"com.twilo.videoapp.api";


@implementation TwilioVideoAppAPI

- (void)retrieveAccessTokenForIdentity:(NSString *)identity
                              roomName:(NSString *)roomName
                             authToken:(NSString *)authToken
                           environment:(TwilioVideoAppAPIEnvironment)environment
                              topology:(TwilioVideoAppAPITopology)topology
                       completionBlock:(void(^)(NSString *accessToken, NSError *error))completionBlock {
    if (!completionBlock) {
        return;
    }

    NSDictionary<NSString *, NSString *> *params = @{ kTwilioVideoAppAPIIdentityKey : identity,
                                                      kTwilioVideoAppAPIRoomNameKey : roomName,
                                                      kTwilioVideoAppAPIAppEnvironmentKey : [SwiftToObjc appEnvironment],
                                                      kTwilioVideoAppAPITopologyKey : topology
                                                    };

    NSURLComponents *urlComponents = [TwilioVideoAppAPI urlComponentsWithEnvironment:environment
                                                                            endpoint:kTwilioVideoAppAPITokenEndpoint
                                                                              params:params];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{ kTwilioVideoAppAPIAuthorizationHeader : authToken };

    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlComponents.URL];

    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *accessToken = nil;
        if (!error) {
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200) {
                accessToken = responseString;
            } else {
                error = [NSError errorWithDomain:kTwilioVideoAppAPIErrorDomain
                                            code:httpResponse.statusCode
                                        userInfo:@{ NSLocalizedDescriptionKey : responseString }];
            }
        }
        completionBlock(accessToken, error);
    }] resume];
}

+ (NSString *)hostForEnvironment:(TwilioVideoAppAPIEnvironment)environment {
    NSString *envString = @"";

    if (![environment isEqualToString:kTwilioVideoAppAPIEnvironmentProduction]) {
        if ([environment isEqualToString:kTwilioVideoAppAPIEnvironmentStaging]) {
            envString = kTwilioVideoAppAPIStageQualifier;
        } else if ([environment isEqualToString:kTwilioVideoAppAPIDevQualifier]) {
            envString = kTwilioVideoAppAPIDevQualifier;
        }
    }

    return [NSString stringWithFormat:@"%@%@%@", kTwilioVideoAppAPIHostPrefix, envString, kTwilioVideoAppAPIHostSuffix];
}

+ (NSURLComponents *)urlComponentsWithEnvironment:(TwilioVideoAppAPIEnvironment)environment
                                         endpoint:(NSString *)endpoint
                                           params:(NSDictionary<NSString *, NSString *> *)params {
    NSURLComponents *urlComponents = [NSURLComponents new];
    urlComponents.scheme = @"https";
    urlComponents.host = [TwilioVideoAppAPI hostForEnvironment:environment];
    urlComponents.path = endpoint;

    NSMutableArray<NSURLQueryItem *> *queryItems = [NSMutableArray new];

    [params enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        if ([value length] > 0) {
            [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:value]];
        }
    }];

    urlComponents.queryItems = queryItems;

    return urlComponents;
}

@end
