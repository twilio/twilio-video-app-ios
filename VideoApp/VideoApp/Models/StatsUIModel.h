//
//  StatsUIModel.h
//  VideoApp
//
//  Created by Ryan Payne on 3/15/17.
//  Copyright © 2017 Twilio, Inc. All rights reserved.
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
                                 connectionId:(NSString *)connectionId;
- (instancetype)initWithSignalingRegion:(NSString *)signalingRegion
                            mediaRegion:(NSString *)mediaRegion;

- (instancetype)init __attribute__((unavailable("StatsUIModel must be created with a parameterized initializer.")));

- (NSString *)titleForAttributeIndex:(NSUInteger)attributeIndex;
- (NSString *)valueForAttributeIndex:(NSUInteger)attributeIndex;

@end
