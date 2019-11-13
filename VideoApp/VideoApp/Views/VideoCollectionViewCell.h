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
