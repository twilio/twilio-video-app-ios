//
//  RemoteParticipantUIModel.m
//  VideoApp
//
//  Created by Ryan Payne on 5/31/17.
//  Copyright © 2017 Twilio, Inc. All rights reserved.
//

#import "RemoteParticipantUIModel.h"

@import TwilioVideo;

@interface RemoteParticipantUIModel ()

@property (nonatomic, nonnull) TVIRemoteParticipant *remoteParticipant;
@property (nonatomic, nullable) TVIRemoteVideoTrack *remoteVideoTrack;

@end

@implementation RemoteParticipantUIModel

- (nullable instancetype)initWithRemoteParticipant:(nonnull TVIRemoteParticipant *)remoteParticipant videoTrack:(nullable TVIRemoteVideoTrack *)videoTrack {
    self = [super init];

    if (self) {
        self.remoteParticipant = remoteParticipant;
        self.remoteVideoTrack = videoTrack;
    }

    return self;
}

- (BOOL)isEqual:(id)object {
    BOOL isEqual = NO;

    if ([object isKindOfClass:[RemoteParticipantUIModel class]]) {
        RemoteParticipantUIModel *otherObject = (RemoteParticipantUIModel *)object;

        if ([self.remoteParticipant isEqual:otherObject.remoteParticipant]) {
            isEqual = (self.remoteVideoTrack == nil && otherObject.remoteVideoTrack == nil) || [self.remoteVideoTrack isEqual:otherObject.remoteVideoTrack];
        }
    }

    return isEqual;
}

- (NSUInteger)hash {
    return [self.remoteParticipant hash] ^ [self.remoteVideoTrack hash];
}

@end
