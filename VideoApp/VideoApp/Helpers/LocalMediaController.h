//
//  LocalMediaController.h
//  VideoApp
//
//  Created by Ryan Payne on 5/17/17.
//  Copyright © 2017 Twilio, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import TwilioVideo;

@protocol LocalMediaControllerDelegate;

@interface LocalMediaController : NSObject

@property (nonatomic, readonly, nullable) TVILocalAudioTrack *localAudioTrack;
@property (nonatomic, readonly, nullable) TVILocalVideoTrack *localVideoTrack;
@property (nonatomic, weak, nullable) TVILocalParticipant *localParticipant;

// Delegate Management
- (void)addDelegate:(nonnull id <LocalMediaControllerDelegate>)delegate;
- (void)removeDelegate:(nonnull id <LocalMediaControllerDelegate>)delegate;

// Audio Management
- (void)createLocalAudioTrack;
- (void)destroyLocalAudioTrack;

// Video Management
- (void)createLocalVideoTrack;
- (void)destroyLocalVideoTrack;
- (void)flipCamera;

@property (nonatomic, readonly, getter=shouldMirrorLocalVideoView) BOOL mirrorLocalVideoView;

@end


@protocol LocalMediaControllerDelegate <NSObject>

@optional

-(void)localMediaControllerStartedVideoCapture:(nonnull LocalMediaController *)localMediaController;

@end
