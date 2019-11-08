//
//  VideoAppCamera.h
//  VideoApp
//
//  Created by Ryan Payne on 12/14/18.
//  Copyright © 2018 Twilio, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import TwilioVideo;
@class LocalMediaController;

@protocol VideoAppCamera <NSObject>

@property (nonatomic, strong, nullable, readonly) TVILocalVideoTrack *localVideoTrack;

- (_Nonnull instancetype)initWithLocalMediaController:(nonnull LocalMediaController *)localMediaController;

- (void)destroyLocalVideoTrack;

- (void)flipCamera;

- (BOOL)shouldMirrorLocalVideoView;

@end
