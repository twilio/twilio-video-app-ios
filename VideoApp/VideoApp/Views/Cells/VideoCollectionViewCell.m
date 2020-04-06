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

#import "VideoCollectionViewCell.h"
#import "RemoteParticipantUIModel.h"
#import "VideoApp-Swift.h"

@import TwilioVideo;

@interface VideoCollectionViewCell () <TVIVideoViewDelegate>

@property (nonatomic, weak) TVILocalParticipant *localParticipant;
@property (nonatomic, weak) RemoteParticipantUIModel *remoteParticipantUIModel;
@property (nonatomic, weak) TVIVideoTrack *videoTrack;
@property (nonatomic, assign, getter=isDominantSpeaker) BOOL dominantSpeaker;

@property (nonatomic, weak) IBOutlet UIView *audioMutedImage;
@property (nonatomic, weak) IBOutlet UIView *dominantSpeakerIndicatorImage;
@property (nonatomic, weak) IBOutlet UIImageView *networkQualityLevelIndicator;

// Displayed when we have no video
@property (nonatomic, weak) IBOutlet UIImageView *noVideoImage;
@property (nonatomic, weak) IBOutlet UILabel *noVideoIdentityLabel;

// Displayed when we have video
@property (nonatomic, weak) IBOutlet UIView *identityContainerView;
@property (nonatomic, weak) IBOutlet UILabel *identityLabel;
@property (nonatomic, strong) TVIVideoView *videoView;

@end

@implementation VideoCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.layer.backgroundColor = CGColorCreateCopyWithAlpha(self.layer.backgroundColor, 0.8);
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 2;

    self.audioMutedImage.layer.cornerRadius = self.audioMutedImage.bounds.size.width / 2.0;
    self.audioMutedImage.layer.backgroundColor = CGColorCreateCopyWithAlpha([UIColor blackColor].CGColor, 0.5);

    self.dominantSpeakerIndicatorImage.layer.cornerRadius = self.dominantSpeakerIndicatorImage.bounds.size.width / 2.0;
    self.dominantSpeakerIndicatorImage.layer.backgroundColor = CGColorCreateCopyWithAlpha([UIColor blackColor].CGColor, 0.5);

    self.networkQualityLevel = TVINetworkQualityLevelUnknown;

    [self updateUIForVideoTrack:NO];
    [self updateUIForAudioState];
}

- (void)dealloc {
    if (_videoView) {
        [_videoTrack removeRenderer:_videoView];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];

    self.videoTrack = nil;
    self.audioMutedImage.hidden = NO;
    self.dominantSpeakerIndicatorImage.hidden = YES;
    self.dominantSpeaker = NO;
    self.networkQualityLevel = TVINetworkQualityLevelUnknown;

    _localParticipant = nil;
    _remoteParticipantUIModel = nil;

    self.videoView.hidden = YES;
}

- (void)setLocalParticipant:(TVILocalParticipant *)localParticipant isCurrentlySelected:(BOOL)isCurrentlySelected {
    if (localParticipant) {
        _localParticipant = localParticipant;
        _remoteParticipantUIModel = nil;
        self.dominantSpeaker = NO;
        self.networkQualityLevel = localParticipant.networkQualityLevel;

        [self setIdentity:@"You"];
        [self updateUIForAudioState];

        if (!isCurrentlySelected && [_localParticipant.videoTracks count] > 0) {
            self.videoTrack = _localParticipant.localVideoTracks[0].localTrack;
        } else {
            [self updateUIForVideoTrack:NO];
        }
    }
}

- (void)setRemoteParticipantUIModel:(RemoteParticipantUIModel *)remoteParticipantUIModel
                  isDominantSpeaker:(BOOL)isDominantSpeaker {
    if (remoteParticipantUIModel) {
        _remoteParticipantUIModel = remoteParticipantUIModel;
        _localParticipant = nil;
        self.dominantSpeaker = isDominantSpeaker;
        self.networkQualityLevel = remoteParticipantUIModel.remoteParticipant.networkQualityLevel;

        TVIParticipant *remoteParticipant = _remoteParticipantUIModel.remoteParticipant;

        [self setIdentity:remoteParticipant.identity];
        [self updateUIForAudioState];

        self.videoTrack = _remoteParticipantUIModel.remoteVideoTrack;
    }
}

- (void)setIdentity:(NSString *)identity {
    self.identityLabel.text = identity;
    self.noVideoIdentityLabel.text = identity;
}

- (void)setVideoTrack:(TVIVideoTrack *)videoTrack {
    if (videoTrack && !self.videoView) {
        self.videoView = [[TVIVideoView alloc] initWithFrame:self.contentView.frame delegate:self];
        self.videoView.contentMode = UIViewContentModeScaleAspectFill;
        self.videoView.hidden = YES;
        [self.contentView insertSubview:self.videoView atIndex:0];
    }

    if (_videoTrack) {
        [_videoTrack removeRenderer:self.videoView];
    }

    _videoTrack = videoTrack;

    if (_videoTrack && _videoTrack.isEnabled) {
        [_videoTrack addRenderer:self.videoView];

        if ([_videoTrack isKindOfClass:[TVILocalVideoTrack class]]) {
            TVILocalVideoTrack *localVideoTrack = (TVILocalVideoTrack *)_videoTrack;
            self.videoView.mirror = localVideoTrack.shouldMirror;
        }
    }

    [self updateUIForVideoTrack:_videoTrack.isEnabled];
}

- (void)setNetworkQualityLevel:(TVINetworkQualityLevel)networkQualityLevel {
    if (networkQualityLevel == TVINetworkQualityLevelUnknown) {
        self.networkQualityLevelIndicator.hidden = YES;
        self.networkQualityLevelIndicator.image = nil;
    } else {
        self.networkQualityLevelIndicator.hidden = NO;
        self.networkQualityLevelIndicator.image = [NetworkQualityIndicator networkQualityIndicatorImageForLevel:networkQualityLevel];
    }
}

- (void)updateUIForVideoTrack:(BOOL)hasVideoTrack {
    self.noVideoImage.hidden = hasVideoTrack;
    self.noVideoIdentityLabel.hidden = hasVideoTrack;

    self.identityContainerView.hidden = !hasVideoTrack;
    self.identityLabel.hidden = !hasVideoTrack;

    self.videoView.hidden = !(self.videoView.hasVideoData && hasVideoTrack);
    [self sendSubviewToBack:self.videoView];
}

- (void)updateUIForAudioState {
    BOOL shouldHideDominantSpeakerIndicator = YES;
    BOOL shouldHideAudioMutedIndicator = YES;

    if (self.localParticipant != nil) {
        shouldHideAudioMutedIndicator = [self.localParticipant.audioTracks count] > 0 && self.localParticipant.audioTracks[0].track.isEnabled;
    } else if (self.remoteParticipantUIModel.remoteParticipant != nil) {
        if (self.isDominantSpeaker) {
            shouldHideDominantSpeakerIndicator = NO;
        } else {
            TVIRemoteParticipant *remoteParticipant = self.remoteParticipantUIModel.remoteParticipant;
            shouldHideAudioMutedIndicator = [remoteParticipant.audioTracks count] > 0 && remoteParticipant.audioTracks[0].track.isEnabled;
        }
    }

    self.dominantSpeakerIndicatorImage.hidden = shouldHideDominantSpeakerIndicator;
    self.audioMutedImage.hidden = shouldHideAudioMutedIndicator;
}

#pragma mark - TVIVideoViewDelegate
- (void)videoViewDidReceiveData:(TVIVideoView *)view {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.videoView.hidden = NO;
    [self sendSubviewToBack:self.videoView];
}

- (void)videoView:(TVIVideoView *)view videoDimensionsDidChange:(CMVideoDimensions)dimensions {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)videoView:(TVIVideoView *)view videoOrientationDidChange:(TVIVideoOrientation)orientation {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
