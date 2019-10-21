//
//  VideoCollectionViewCell.h
//  VideoApp
//
//  Created by Ryan Payne on 5/22/17.
//  Copyright © 2017 Twilio, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@import TwilioVideo;

@class RemoteParticipantUIModel;

@interface VideoCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) TVINetworkQualityLevel networkQualityLevel;

// A cell can only have one or the other. If you set one, it nil's the other
@property (nonatomic, readonly, weak) TVILocalParticipant *localParticipant;
- (void)setLocalParticipant:(TVILocalParticipant *)localParticipant isCurrentlySelected:(BOOL)isCurrentlySelected;

@property (nonatomic, readonly, weak) RemoteParticipantUIModel *remoteParticipantUIModel;
- (void)setRemoteParticipantUIModel:(RemoteParticipantUIModel *)remoteParticipantUIModel isDominantSpeaker:(BOOL)isDominantSpeaker;

@end
