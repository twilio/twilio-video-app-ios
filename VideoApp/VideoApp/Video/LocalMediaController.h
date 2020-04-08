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

- (void)cameraSourceWasInterrupted;
- (void)cameraSourceInterruptionEnded;
- (void)videoCaptureStarted;
- (void)checkVideoSenderSettings:(BOOL)isMultiparty;

@property (nonatomic, readonly, getter=shouldMirrorLocalVideoView) BOOL mirrorLocalVideoView;

@end


@protocol LocalMediaControllerDelegate <NSObject>

@optional

-(void)localMediaControllerStartedVideoCapture:(nonnull LocalMediaController *)localMediaController;

@end
