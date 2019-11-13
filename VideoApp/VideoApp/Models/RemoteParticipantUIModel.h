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

@class TVIRemoteParticipant;
@class TVIRemoteVideoTrack;

@interface RemoteParticipantUIModel : NSObject

@property (nonatomic, nonnull, readonly) TVIRemoteParticipant *remoteParticipant;
@property (nonatomic, nullable, readonly) TVIRemoteVideoTrack *remoteVideoTrack;

- (nullable instancetype)initWithRemoteParticipant:(nonnull TVIRemoteParticipant *)remoteParticipant videoTrack:(nullable TVIRemoteVideoTrack *)videoTrack;

- (null_unspecified instancetype)init NS_UNAVAILABLE;

@end
