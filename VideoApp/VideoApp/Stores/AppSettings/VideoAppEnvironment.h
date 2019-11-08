//
//  VideoAppEnvironment.h
//  VideoApp
//
//  Created by Piyush Tank on 11/14/17.
//  Copyright © 2017 Twilio, Inc. All rights reserved.
//

#ifndef VideoAppEnvironment_h
#define VideoAppEnvironment_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, VideoAppEnvironment) {
    VideoAppEnvironmentTwilio = 0,
    VideoAppEnvironmentInternal,
    VideoAppEnvironmentCommunity
};

extern const VideoAppEnvironment gCurrentAppEnvironment;

#endif /* VideoAppEnvironment_h */
