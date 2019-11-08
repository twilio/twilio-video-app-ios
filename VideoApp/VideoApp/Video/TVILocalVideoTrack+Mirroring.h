//
//  TVILocalVideoTrack+Mirroring.h
//  VideoApp
//
//  Created by Ryan Payne on 12/17/18.
//  Copyright © 2018 Twilio, Inc. All rights reserved.
//

#import <TwilioVideo/TwilioVideo.h>
@import TwilioVideo;

@interface TVILocalVideoTrack (Mirroring)

- (BOOL)tvi_shouldMirror;

@end

