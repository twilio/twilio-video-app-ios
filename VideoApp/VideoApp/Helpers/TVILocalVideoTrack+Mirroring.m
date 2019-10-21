//
//  TVILocalVideoTrack+Mirroring.m
//  VideoApp
//
//  Created by Ryan Payne on 12/17/18.
//  Copyright © 2018 Twilio, Inc. All rights reserved.
//

#import "TVILocalVideoTrack+Mirroring.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"

@implementation TVILocalVideoTrack (Mirroring)

- (BOOL)tvi_shouldMirror {
    BOOL shouldMirror = NO;

    if (self.source != nil && [self.source isKindOfClass:[TVICameraSource class]]) {
        TVICameraSource *cameraSource = (TVICameraSource *)self.source;
        shouldMirror = (cameraSource.device.position == AVCaptureDevicePositionFront);
    }

    return shouldMirror;
}

@end

#pragma clang diagnostic pop
