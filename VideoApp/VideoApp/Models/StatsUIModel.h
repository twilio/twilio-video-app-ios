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

@class TVIRemoteAudioTrackStats;
@class TVIRemoteVideoTrackStats;
@class TVILocalAudioTrackStats;
@class TVILocalVideoTrackStats;
@class TVIIceCandidatePairStats;
@class TVIIceCandidateStats;

@interface StatsUIModel : NSObject

@property (nonatomic, readonly, copy)   NSString *title;
@property (nonatomic, readonly, assign) NSUInteger attributeCount;
@property (nonatomic, readonly, assign, getter=isLocalTrack) BOOL localTrack;
@property (nonatomic, readonly, assign, getter=isAudioTrack) BOOL audioTrack;

- (instancetype)initWithRemoteAudioTrackStats:(TVIRemoteAudioTrackStats *)remoteAudioTrackStats trackName:(NSString *)trackName;
- (instancetype)initWithRemoteVideoTrackStats:(TVIRemoteVideoTrackStats *)remoteVideoTrackStats trackName:(NSString *)trackName;
- (instancetype)initWithLocalAudioTrackStats:(TVILocalAudioTrackStats *)localAudioTrackStats trackName:(NSString *)trackName;
- (instancetype)initWithLocalVideoTrackStats:(TVILocalVideoTrackStats *)localVideoTrackStats trackName:(NSString *)trackName;
- (instancetype)initWithIceCandidatePairStats:(TVIIceCandidatePairStats *)icePairStats
                               localCandidate:(TVIIceCandidateStats *)localCandidate
                              remoteCandidate:(TVIIceCandidateStats *)remoteCandidate
                                lastPairStats:(TVIIceCandidatePairStats *)lastIcePairStats
                                     lastDate:(NSDate *)lastDate
                                 connectionId:(NSString *)connectionId;
- (instancetype)initWithSignalingRegion:(NSString *)signalingRegion
                            mediaRegion:(NSString *)mediaRegion;
- (instancetype)initWithThermalState:(NSProcessInfoThermalState)state
                         cpuAverages:(NSArray<NSNumber *> *)cpu;

- (instancetype)init __attribute__((unavailable("StatsUIModel must be created with a parameterized initializer.")));

- (NSString *)titleForAttributeIndex:(NSUInteger)attributeIndex;
- (NSString *)valueForAttributeIndex:(NSUInteger)attributeIndex;

@end
