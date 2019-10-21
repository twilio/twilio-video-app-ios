//
//  RemoteParticipantUIModel.h
//  VideoApp
//
//  Created by Ryan Payne on 5/31/17.
//  Copyright © 2017 Twilio, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TVIRemoteParticipant;
@class TVIRemoteVideoTrack;

@interface RemoteParticipantUIModel : NSObject

@property (nonatomic, nonnull, readonly) TVIRemoteParticipant *remoteParticipant;
@property (nonatomic, nullable, readonly) TVIRemoteVideoTrack *remoteVideoTrack;

- (nullable instancetype)initWithRemoteParticipant:(nonnull TVIRemoteParticipant *)remoteParticipant videoTrack:(nullable TVIRemoteVideoTrack *)videoTrack;

- (null_unspecified instancetype)init NS_UNAVAILABLE;

@end
