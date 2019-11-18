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

#import "LocalMediaController.h"
#import "VideoAppCamera.h"
#import "VideoAppCameraSource.h"

@interface LocalMediaController ()

@property (nonatomic, strong, nullable) TVILocalAudioTrack *localAudioTrack;
@property (nonatomic, strong) id <VideoAppCamera> camera;
@property (nonatomic, strong) NSPointerArray *delegates;

@end

@implementation LocalMediaController

- (instancetype)init {
    self = [super init];

    if (self) {
        _delegates = [NSPointerArray weakObjectsPointerArray];
    }

    return self;
}

#pragma mark - Local Participant Management
- (void)setLocalParticipant:(TVILocalParticipant *)localParticipant {
    _localParticipant = localParticipant;

    // There is the potential for a race condition when we destroy the audio/video track after it has
    // been added to the connect options but before the Room connects and the local participant has been set here. The
    // similar issue can happen if you initially join the room with no audio track and then add one before the local
    // participant has been set here.
    if (localParticipant != nil) {
        if (self.localAudioTrack == nil &&
            [localParticipant.localAudioTracks count] > 0) {
            for (TVILocalAudioTrackPublication *trackPublication in localParticipant.localAudioTracks) {
                [localParticipant unpublishAudioTrack:trackPublication.localTrack];
            }
        } else if (self.localAudioTrack != nil &&
                   [localParticipant.localAudioTracks count] == 0) {
            [localParticipant publishAudioTrack:self.localAudioTrack];
        }

        if (self.localVideoTrack == nil &&
            [localParticipant.localVideoTracks count] > 0) {
            for (TVILocalVideoTrackPublication *trackPublication in localParticipant.localVideoTracks) {
                [localParticipant unpublishVideoTrack:trackPublication.localTrack];
            }
        } else if (self.localVideoTrack != nil &&
                   [localParticipant.localVideoTracks count] == 0) {
            [localParticipant publishVideoTrack:self.localVideoTrack];
        }
    }
}

#pragma mark - Audio Management
- (void)createLocalAudioTrack {
    if (self.localAudioTrack == nil) {
        self.localAudioTrack = [TVILocalAudioTrack trackWithOptions:[TVIAudioOptions options] enabled:YES name:@"Microphone"];

        if (!self.localAudioTrack) {
            NSLog(@"Failed to create audio track");
        } else if (self.localParticipant) {
            [self.localParticipant publishAudioTrack:self.localAudioTrack];
        }
    }
}

- (void)destroyLocalAudioTrack {
    if (self.localAudioTrack != nil) {
        [self.localParticipant unpublishAudioTrack:self.localAudioTrack];
        self.localAudioTrack = nil;
    } else {
        NSLog(@"No local audio track to remove");
    }
}

#pragma mark - Video Management
- (void)createLocalVideoTrack {
    if (self.localVideoTrack == nil) {
        self.camera = [[VideoAppCameraSource alloc] initWithLocalMediaController:self];
    }

    if (!self.localVideoTrack) {
        NSLog(@"Failed to create video track");
    } else if (self.localParticipant) {
        [self.localParticipant publishVideoTrack:self.camera.localVideoTrack];
    }
}

- (TVILocalVideoTrack *)localVideoTrack {
    return self.camera.localVideoTrack;
}

- (void)destroyLocalVideoTrack {
    if (self.camera.localVideoTrack != nil) {
        [self.localParticipant unpublishVideoTrack:self.camera.localVideoTrack];
        [self.camera destroyLocalVideoTrack];
        self.camera = nil;
    } else {
        NSLog(@"No local video track to unpublish");
    }
}

- (void)flipCamera {
    [self.camera flipCamera];
}

- (BOOL)shouldMirrorLocalVideoView {
    return self.camera.shouldMirrorLocalVideoView;
}

#pragma mark - Delegate management
- (void)addDelegate:(id)delegate {
    if (delegate && [delegate conformsToProtocol:@protocol(LocalMediaControllerDelegate)]) {
        @synchronized(self) {
            [self.delegates addPointer:(__bridge void *)delegate];
        }
    }
}

- (void)removeDelegate:(id)delegate {
    if (delegate) {
        void *ptr = (__bridge void *)delegate;

        @synchronized(self) {
            for (NSUInteger i = 0; i < [self.delegates count]; i++) {
                if ([self.delegates pointerAtIndex:i] == ptr) {
                    [self.delegates removePointerAtIndex:i];
                    break;
                }
            }
        }
    }
}

- (void)videoCaptureStarted {
    @synchronized(self) {
        for (id delegate in self.delegates) {
            if (delegate &&
                [delegate conformsToProtocol:@protocol(LocalMediaControllerDelegate)] &&
                [delegate respondsToSelector:@selector(localMediaControllerStartedVideoCapture:)]) {
                [delegate localMediaControllerStartedVideoCapture:self];
            }
        }
    }
}

@end
