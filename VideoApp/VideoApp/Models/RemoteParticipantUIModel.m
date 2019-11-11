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
