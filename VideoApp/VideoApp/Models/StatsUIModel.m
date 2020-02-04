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

#import "StatsUIModel.h"
@import TwilioVideo;

static NSString *const kStatsUIModelTitleSid = @"sid";
static NSString *const kStatsUIModelTitleCodec = @"codec";
static NSString *const kStatsUIModelTitlePacketLost = @"packets lost";
static NSString *const kStatsUIModelTitleBytesSent = @"bytes sent";
static NSString *const kStatsUIModelTitleBytesReceived = @"bytes received";
static NSString *const kStatsUIModelTitleBitrateSent = @"bitrate sent";
static NSString *const kStatsUIModelTitleBitrateReceived = @"bitrate received";
static NSString *const kStatsUIModelTitleRoundTripTime = @"round trip time";
static NSString *const kStatsUIModelTitleJitter = @"jitter";
static NSString *const kStatsUIModelTitleAudioLevel = @"audio level";
static NSString *const kStatsUIModelTitleDimensions = @"dimensions";
static NSString *const kStatsUIModelTitleFrameRate = @"frame rate";
static NSString *const kStatsUIModelTitleCaptureDimensions = @"capture dimensions";
static NSString *const kStatsUIModelTitleCaptureFrameRate = @"capture frame rate";
static NSString *const kStatsUIModelTitleLocalCandidateIp = @"local ip";
static NSString *const kStatsUIModelTitleLocalCandidatePort = @"local port";
static NSString *const kStatsUIModelTitleLocalCandidateType = @"local type";
static NSString *const kStatsUIModelTitleLocalCandidateProtocol = @"local protocol";
static NSString *const kStatsUIModelTitleMediaRegion = @"media";
static NSString *const kStatsUIModelTitleRemoteCandidateIp = @"remote ip";
static NSString *const kStatsUIModelTitleRemoteCandidatePort = @"remote port";
static NSString *const kStatsUIModelTitleRemoteCandidateType = @"remote type";
static NSString *const kStatsUIModelTitleRemoteCandidateProtocol = @"remote protocol";
static NSString *const kStatsUIModelTitleParticipantSignalingRegion = @"signaling";
static NSString *const kStatsUIModelTitleRelayProtocol = @"relay protocol";
static NSString *const kStatsUIModelTitleTransportId = @"transport id";

@interface StatsUIModel ()

@property (nonatomic, copy)   NSString *title;
@property (nonatomic, strong) NSMutableArray<NSString *> *attributeTitles;
@property (nonatomic, strong) NSMutableArray<NSString *> *attributeValues;
@property (nonatomic, assign, getter=isLocalTrack) BOOL localTrack;
@property (nonatomic, assign, getter=isAudioTrack) BOOL audioTrack;

@end

@implementation StatsUIModel

- (instancetype)init {
    self = nil;

    NSException *exception = [NSException exceptionWithName:@"StatsUIModelInitializationException" reason:@"StatsUIModel must be initialized with a parameterized initializer." userInfo:nil];
    [exception raise];

    return self;
}

- (instancetype)initWithBaseTrackStats:(TVIBaseTrackStats *)baseTrackStats trackName:(NSString *)trackName {
    self = [super init];

    if (self != nil) {
        _localTrack = NO;
        _audioTrack = NO;

        _attributeTitles = [NSMutableArray new];
        _attributeValues = [NSMutableArray new];

        _title = trackName;

        // id
        [_attributeTitles addObject:kStatsUIModelTitleSid];
        [_attributeValues addObject:([baseTrackStats.trackSid length] > 6 ? [baseTrackStats.trackSid substringToIndex:6] : baseTrackStats.trackSid)];

        // codec
        [_attributeTitles addObject:kStatsUIModelTitleCodec];
        [_attributeValues addObject:baseTrackStats.codec];

        // packets lost
        [_attributeTitles addObject:kStatsUIModelTitlePacketLost];
        [_attributeValues addObject:[NSNumberFormatter localizedStringFromNumber:@(baseTrackStats.packetsLost)
                                                                     numberStyle:NSNumberFormatterDecimalStyle]];
    }

    return self;
}

- (instancetype)initWithLocalTrackStats:(TVILocalTrackStats *)localTrackStats trackName:(NSString *)trackName {
    self = [self initWithBaseTrackStats:localTrackStats trackName:trackName];

    if (self != nil) {
        _localTrack = YES;

        // bytes sent
        [_attributeTitles addObject:kStatsUIModelTitleBytesSent];
        [_attributeValues addObject:[NSNumberFormatter localizedStringFromNumber:@(localTrackStats.bytesSent)
                                                                     numberStyle:NSNumberFormatterDecimalStyle]];

        // round trip time
        [_attributeTitles addObject:kStatsUIModelTitleRoundTripTime];
        [_attributeValues addObject:[NSString stringWithFormat:@"%lld ms", localTrackStats.roundTripTime]];
    }

    return self;
}

- (instancetype)initWithRemoteTrackStats:(TVIRemoteTrackStats *)trackStats trackName:(NSString *)trackName {
    self = [self initWithBaseTrackStats:trackStats trackName:trackName];

    if (self != nil) {
        [_attributeTitles addObject:kStatsUIModelTitleBytesReceived];
        [_attributeValues addObject:[NSNumberFormatter localizedStringFromNumber:@(trackStats.bytesReceived)
                                                                     numberStyle:NSNumberFormatterDecimalStyle]];
    }

    return self;
}

- (instancetype)initWithRemoteAudioTrackStats:(TVIRemoteAudioTrackStats *)audioTrackStats trackName:(NSString *)trackName {
    self = [self initWithRemoteTrackStats:audioTrackStats trackName:trackName];

    if (self != nil) {
        _audioTrack = YES;

        // jitter
        [_attributeTitles addObject:kStatsUIModelTitleJitter];
        [_attributeValues addObject:[NSString stringWithFormat:@"%tu ms", audioTrackStats.jitter]];

        // audio level
        [_attributeTitles addObject:kStatsUIModelTitleAudioLevel];
        [_attributeValues addObject:[NSString stringWithFormat:@"%tu", audioTrackStats.audioLevel]];

        NSAssert([_attributeTitles count] == [_attributeValues count], @"Mismatch in titles and values!");
    }

    return self;
}

- (instancetype)initWithLocalAudioTrackStats:(TVILocalAudioTrackStats *)localAudioTrackStats trackName:(NSString *)trackName {
    self = [self initWithLocalTrackStats:localAudioTrackStats trackName:trackName];

    if (self != nil) {
        _audioTrack = YES;

        // jitter
        [_attributeTitles addObject:kStatsUIModelTitleJitter];
        [_attributeValues addObject:[NSString stringWithFormat:@"%tu ms", localAudioTrackStats.jitter]];

        // audio level
        [_attributeTitles addObject:kStatsUIModelTitleAudioLevel];
        [_attributeValues addObject:[NSNumberFormatter localizedStringFromNumber:@(localAudioTrackStats.audioLevel)
                                                                     numberStyle:NSNumberFormatterDecimalStyle]];


        NSAssert([_attributeTitles count] == [_attributeValues count], @"Mismatch in titles and values!");
    }

    return self;
}

- (instancetype)initWithLocalVideoTrackStats:(TVILocalVideoTrackStats *)localVideoTrackStats trackName:(NSString *)trackName {
    self = [self initWithLocalTrackStats:localVideoTrackStats trackName:trackName];

    if (self != nil) {
        // dimensions
        [_attributeTitles addObject:kStatsUIModelTitleDimensions];
        [_attributeValues addObject:[NSString stringWithFormat:@"%dx%d", localVideoTrackStats.dimensions.width, localVideoTrackStats.dimensions.height]];

        // frame rate
        [_attributeTitles addObject:kStatsUIModelTitleFrameRate];
        [_attributeValues addObject:[NSString stringWithFormat:@"%tu", localVideoTrackStats.frameRate]];

        // capture dimensions
        [_attributeTitles addObject:kStatsUIModelTitleCaptureDimensions];
        [_attributeValues addObject:[NSString stringWithFormat:@"%dx%d", localVideoTrackStats.captureDimensions.width, localVideoTrackStats.captureDimensions.height]];

        // capture frame rate
        [_attributeTitles addObject:kStatsUIModelTitleCaptureFrameRate];
        [_attributeValues addObject:[NSString stringWithFormat:@"%tu", localVideoTrackStats.captureFrameRate]];

        NSAssert([_attributeTitles count] == [_attributeValues count], @"Mismatch in titles and values!");
    }

    return self;
}

- (instancetype)initWithRemoteVideoTrackStats:(TVIRemoteVideoTrackStats *)videoTrackStats trackName:(NSString *)trackName {
    self = [self initWithRemoteTrackStats:videoTrackStats trackName:trackName];

    if (self != nil) {
        // dimensions
        [_attributeTitles addObject:kStatsUIModelTitleDimensions];
        [_attributeValues addObject:[NSString stringWithFormat:@"%dx%d", videoTrackStats.dimensions.width, videoTrackStats.dimensions.height]];
        
        // frame rate
        [_attributeTitles addObject:kStatsUIModelTitleFrameRate];
        [_attributeValues addObject:[NSString stringWithFormat:@"%tu", videoTrackStats.frameRate]];

        NSAssert([_attributeTitles count] == [_attributeValues count], @"Mismatch in titles and values!");
    }

    return self;
}

- (instancetype)initWithIceCandidatePairStats:(TVIIceCandidatePairStats *)icePairStats
                               localCandidate:(TVIIceCandidateStats *)localCandidate
                              remoteCandidate:(TVIIceCandidateStats *)remoteCandidate
                                lastPairStats:(TVIIceCandidatePairStats *)lastIcePairStats
                                     lastDate:(NSDate *)lastDate
                                 connectionId:(NSString *)connectionId {
    self = [super init];

    if (self != nil) {
        _title = connectionId;

        _localTrack = NO;
        _audioTrack = NO;

        _attributeTitles = [NSMutableArray new];
        _attributeValues = [NSMutableArray new];

        [_attributeTitles addObject:kStatsUIModelTitleTransportId];
        [_attributeValues addObject:icePairStats.transportId];

        [_attributeTitles addObject:kStatsUIModelTitleLocalCandidateIp];
        [_attributeValues addObject:localCandidate.ip];

        [_attributeTitles addObject:kStatsUIModelTitleLocalCandidatePort];
        [_attributeValues addObject:[NSNumberFormatter localizedStringFromNumber:@(localCandidate.port)
                                                                     numberStyle:NSNumberFormatterDecimalStyle]];

        [_attributeTitles addObject:kStatsUIModelTitleLocalCandidateType];
        [_attributeValues addObject:localCandidate.candidateType];

        [_attributeTitles addObject:kStatsUIModelTitleLocalCandidateProtocol];
        [_attributeValues addObject:localCandidate.protocol];

        [_attributeTitles addObject:kStatsUIModelTitleRemoteCandidateIp];
        [_attributeValues addObject:remoteCandidate.ip];

        [_attributeTitles addObject:kStatsUIModelTitleRemoteCandidatePort];
        [_attributeValues addObject:[NSNumberFormatter localizedStringFromNumber:@(remoteCandidate.port)
                                                                     numberStyle:NSNumberFormatterDecimalStyle]];

        [_attributeTitles addObject:kStatsUIModelTitleRemoteCandidateType];
        [_attributeValues addObject:remoteCandidate.candidateType];

        [_attributeTitles addObject:kStatsUIModelTitleRemoteCandidateProtocol];
        [_attributeValues addObject:remoteCandidate.protocol];

        [_attributeTitles addObject:kStatsUIModelTitleRelayProtocol];
        [_attributeValues addObject:icePairStats.relayProtocol];

        [_attributeTitles addObject:kStatsUIModelTitleRoundTripTime];
        [_attributeValues addObject:[NSString stringWithFormat:@"%0.1f ms", icePairStats.currentRoundTripTime]];

        NSTimeInterval interval = lastDate ? -1.0 * [lastDate timeIntervalSinceNow] : 1.0;
        int64_t sentDelta = (icePairStats.bytesSent - lastIcePairStats.bytesSent) * (8./(1000. * interval));
        int64_t receivedDelta = (icePairStats.bytesReceived - lastIcePairStats.bytesReceived) * (8./(1000. * interval));

        [_attributeTitles addObject:kStatsUIModelTitleBitrateSent];
        [_attributeValues addObject:[NSString stringWithFormat:@"%@ Kbps",
                                     [NSNumberFormatter localizedStringFromNumber:@(sentDelta)
                                                                      numberStyle:NSNumberFormatterDecimalStyle]]];

        [_attributeTitles addObject:kStatsUIModelTitleBitrateReceived];
        [_attributeValues addObject:[NSString stringWithFormat:@"%@ Kbps",
                                     [NSNumberFormatter localizedStringFromNumber:@(receivedDelta)
                                                                      numberStyle:NSNumberFormatterDecimalStyle]]];

        [_attributeTitles addObject:kStatsUIModelTitleBytesSent];
        [_attributeValues addObject:[NSNumberFormatter localizedStringFromNumber:@(icePairStats.bytesSent)
                                                                     numberStyle:NSNumberFormatterDecimalStyle]];

        [_attributeTitles addObject:kStatsUIModelTitleBytesReceived];
        [_attributeValues addObject:[NSNumberFormatter localizedStringFromNumber:@(icePairStats.bytesReceived)
                                                                     numberStyle:NSNumberFormatterDecimalStyle]];
    }

    return self;
}

- (instancetype)initWithSignalingRegion:(NSString *)signalingRegion
                            mediaRegion:(NSString *)mediaRegion {
    if (self != nil) {
        _title = @"Regions";

        _localTrack = NO;
        _audioTrack = NO;

        _attributeTitles = [NSMutableArray new];
        _attributeValues = [NSMutableArray new];

        [_attributeTitles addObject:kStatsUIModelTitleParticipantSignalingRegion];
        [_attributeValues addObject:signalingRegion];

        if (mediaRegion) {
            [_attributeTitles addObject:kStatsUIModelTitleMediaRegion];
            [_attributeValues addObject:mediaRegion];
        }
    }

    return self;
}

- (NSUInteger)attributeCount {
    return [_attributeTitles count];
}

- (NSString *)titleForAttributeIndex:(NSUInteger)attributeIndex {
    return self.attributeTitles[attributeIndex];
}

- (NSString *)valueForAttributeIndex:(NSUInteger)attributeIndex {
    return self.attributeValues[attributeIndex];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString new];
    [description appendFormat:@"<%@: %p>\n", [[self class] description], self];
    [description appendFormat:@"    title: %@\n", self.title];
    [description appendFormat:@"    isLocalTrack: %@\n", self.isLocalTrack ? @"YES" : @"NO"];
    [description appendFormat:@"    isAudioTrack: %@\n", self.isAudioTrack ? @"YES" : @"NO"];

    for (NSUInteger i = 0; i < self.attributeCount; i++) {
        [description appendFormat:@"    %@: %@\n", [self titleForAttributeIndex:i], [self valueForAttributeIndex:i]];
    }

    return [NSString stringWithString:description];
}

@end
