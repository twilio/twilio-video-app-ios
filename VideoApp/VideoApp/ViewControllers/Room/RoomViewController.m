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

#import "RoomViewController.h"
#import "LocalMediaController.h"
#import "VariableAlphaToggleButton.h"
#import "RoundButton.h"
#import "StatsViewController.h"
#import "StatsUIModel.h"
#import "VideoCollectionViewCell.h"
#import "RemoteParticipantUIModel.h"
#import "VideoApp-Swift.h"

@import TwilioVideo;

@interface RoomViewController () <LocalMediaControllerDelegate,
                                  TVIRoomDelegate,
                                  TVILocalParticipantDelegate,
                                  TVIRemoteParticipantDelegate,
                                  UICollectionViewDelegate,
                                  UICollectionViewDataSource>

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UILabel *mainLabel;
@property (nonatomic, weak) IBOutlet UILabel *joiningLabel;
@property (nonatomic, weak) IBOutlet UILabel *joiningRoomLabel;
@property (nonatomic, weak) IBOutlet UILabel *recordingWarningLabel;
@property (nonatomic, weak) IBOutlet UILabel *noVideoParticipantLabel;
@property (nonatomic, weak) IBOutlet UIImageView *noVideoImageView;
@property (nonatomic, weak) IBOutlet UICollectionView *videoCollectionView;
@property (nonatomic, weak) IBOutlet UIImageView *recordingIndicator;

@property (nonatomic, weak) IBOutlet UIView *remoteParticipantLabelView;
@property (nonatomic, weak) IBOutlet UILabel *remoteParticipantLabel;
@property (nonatomic, weak) IBOutlet UIImageView *remoteParticipantMutedStateImage;
@property (nonatomic, weak) IBOutlet UIImageView *remoteParticipantDominantSpeakerIndicatorImage;
@property (weak, nonatomic) IBOutlet UIImageView *remoteParticipantNetworkQualityIndicator;

@property (nonatomic, weak) IBOutlet VariableAlphaToggleButton *audioToggleButton;
@property (nonatomic, weak) IBOutlet VariableAlphaToggleButton *videoToggleButton;
@property (nonatomic, weak) IBOutlet RoundButton *hangupButton;
@property (nonatomic, weak) IBOutlet UIButton *flipCameraButton;
@property (nonatomic, weak) IBOutlet TVIVideoView *largeVideoView;

@property (nonatomic, strong) TVIRoom *room;

@property (nonatomic, weak) StatsViewController *statsViewController;

@property (nonatomic, strong) RemoteParticipantUIModel *selectedParticipantUIModel;
@property (nonatomic, strong) NSMutableArray<RemoteParticipantUIModel *> *remoteParticipantUIModels;

@property (nonatomic, strong) TVIRemoteParticipant *currentDominantSpeaker;

@end

@implementation RoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Stats view controller
    self.statsViewController = (StatsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"statsViewController"];
    [self.statsViewController addAsSwipeableViewToParentViewController:self];

    self.mainLabel.text = SwiftToObjc.userDisplayName;
    self.joiningRoomLabel.text = self.roomName;

    self.remoteParticipantLabelView.layer.cornerRadius = self.remoteParticipantLabelView.bounds.size.width / 2.0;
    self.remoteParticipantLabelView.layer.backgroundColor = CGColorCreateCopyWithAlpha(self.remoteParticipantLabelView.layer.backgroundColor, 0.5);

    // Make sure the video and container views are still at the back of the stack... They're being... Difficult...
    [self.view sendSubviewToBack:self.containerView];
    [self.view sendSubviewToBack:self.largeVideoView];

    self.videoCollectionView.hidden = YES;

    self.remoteParticipantUIModels = [NSMutableArray new];

    [self fetchAccessToken];
}

- (BOOL)isModalInPresentation {
    // Swiping to dismiss the RoomViewController does not disconnect from the Room. Press the disconnect button instead.
    return YES;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return self.room.state == TVIRoomStateConnected;
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    [self.view setNeedsUpdateConstraints];
}

- (void)fetchAccessToken {
    typeof(self) __weak weakSelf = self;

    [SwiftToObjc fetchTwilioAccessTokenWithRoomName:self.roomName completion:^(NSString *accessToken, NSString *error) {
        typeof(self) __strong strongSelf = weakSelf;

        if (accessToken != nil) {
            [strongSelf joinRoomWithAccessToken:accessToken];
        } else {
            [strongSelf displayErrorWithTitle:@"Token Retrieval Failure" message:error];
        }
    }];
}

- (void)displayErrorWithTitle:(NSString *)title message:(NSString *)message {
    typeof(self) __weak weakSelf = self;

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        typeof(self) __strong strongSelf = weakSelf;
        [strongSelf dismissViewController];
    }];

    [alertController addAction:okAction];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}

- (void)handleRoomError:(NSError *)error onConnect:(BOOL)onConnect {
    NSString *title;
    NSString *message;

    if (onConnect) {
        title = @"Room Connection Error";
        message = [NSString stringWithFormat:@"Unable to connect to room: %@\n\nError: %@",
                   self.roomName,
                   error.localizedDescription];
    } else {
        title = @"Room Error";
        message = [NSString stringWithFormat:@"Error with room: %@\n\nError: %@",
                   self.roomName,
                   error.localizedDescription];
    }

    [self displayErrorWithTitle:title message:message];
}

- (void)joinRoomWithAccessToken:(NSString *)accessToken {
    // Allocate a higher bitrate for the simulcast track with 3 spatial layers.
    int32_t videoBitrate = SwiftToObjc.enableVP8Simulcast ? 1600 : 1200;
    
    TVIConnectOptions *options = [TVIConnectOptions optionsWithToken:accessToken
                                                               block:^(TVIConnectOptionsBuilder *builder) {
        builder.roomName = self.roomName;
        builder.dominantSpeakerEnabled = YES;
        builder.networkQualityEnabled = YES;
        builder.networkQualityConfiguration = [[TVINetworkQualityConfiguration alloc] initWithLocalVerbosity:TVINetworkQualityVerbosityMinimal
                                                                                             remoteVerbosity:TVINetworkQualityVerbosityMinimal];
        builder.audioTracks = self.localMediaController.localAudioTrack ? @[self.localMediaController.localAudioTrack] : @[];
        builder.videoTracks = self.localMediaController.localVideoTrack ? @[self.localMediaController.localVideoTrack] : @[];
        
        if (SwiftToObjc.enableVP8Simulcast) {
            builder.preferredVideoCodecs = @[[[TVIVp8Codec alloc] initWithSimulcast:YES]];
        } else {
            builder.preferredVideoCodecs = @[[TVIH264Codec new]];
        }
        builder.encodingParameters = [[TVIEncodingParameters alloc] initWithAudioBitrate:0
                                                                            videoBitrate:videoBitrate];
        
        if (SwiftToObjc.forceTURNMediaRelay) {
            builder.iceOptions = [TVIIceOptions optionsWithBlock:^(TVIIceOptionsBuilder * _Nonnull builder) {
                builder.abortOnIceServersTimeout = YES;
                builder.iceServersTimeout = 30;
                builder.transportPolicy = TVIIceTransportPolicyRelay;
            }];
        }
    }];
    
    self.room = [TwilioVideoSDK connectWithOptions:options delegate:self];
    self.statsViewController.room = self.room;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [UIApplication sharedApplication].idleTimerDisabled = YES;

    [self.localMediaController addDelegate:self];

    self.audioToggleButton.selected = !self.localMediaController.localAudioTrack;
    self.videoToggleButton.selected = !self.localMediaController.localVideoTrack;
    self.flipCameraButton.enabled = (self.localMediaController.localVideoTrack != nil);

    [self updateVideoUIForSelectedParticipantUIModel:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].idleTimerDisabled = NO;

    // I am not sure the best approach here yet... I wonder what will happen as we have other participant video showing on the main stage...
    [self.localMediaController removeDelegate:self];

    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.localMediaController.localVideoTrack removeRenderer:self.largeVideoView];

    [super viewDidDisappear:animated];
}

- (void)dismissViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)toggleAudioPressed:(id)sender {
    if (self.localMediaController.localAudioTrack) {
        [self.localMediaController destroyLocalAudioTrack];
        [self refreshLocalParticipantVideoView];
    } else {
        [self.localMediaController createLocalAudioTrack];
    }

    self.audioToggleButton.selected = !self.localMediaController.localAudioTrack;
}

- (IBAction)toggleVideoPressed:(id)sender {
    if (self.localMediaController.localVideoTrack) {
        [self.localMediaController destroyLocalVideoTrack];
        self.flipCameraButton.enabled = NO;
        [self refreshLocalParticipantVideoView];
    } else {
        [self.localMediaController createLocalVideoTrack];
        self.flipCameraButton.enabled = YES;
    }

    self.videoToggleButton.selected = !self.localMediaController.localVideoTrack;

    if (self.selectedParticipantUIModel == nil) {
        // We are displaying ourselves in the big view...
        [self updateVideoUIForSelectedParticipantUIModel:nil];
    }
}

- (IBAction)hangupPressed:(id)sender {
    self.statsViewController.room = nil;

    if (self.room) {
        [self.room disconnect];
    } else {
        [self dismissViewController];
    }
}

- (IBAction)flipCameraPressed:(id)sender {
    [self.localMediaController flipCamera];
}

- (void)refreshLocalParticipantVideoView {
    // Our local Participant is always first.
    [self.videoCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]];
}

- (void)refreshParticipantVideoViews:(TVIParticipant *)participant {
    NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray new];

    for (VideoCollectionViewCell *cell in self.videoCollectionView.visibleCells) {
        if ([cell.remoteParticipantUIModel.remoteParticipant isEqual:participant]) {
            NSIndexPath *indexPath = [self.videoCollectionView indexPathForCell:cell];

            if (indexPath) {
                [indexPaths addObject:indexPath];
            }
        }
    }

    if (indexPaths.count > 0) {
        [self.videoCollectionView reloadItemsAtIndexPaths:indexPaths];
    }
}

- (void)refreshVideoViews {
    [self.videoCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

- (void)updateVideoUIForSelectedParticipantUIModel:(RemoteParticipantUIModel *)selectedParticipantUIModel {
    RemoteParticipantUIModel *previouslySelectedParticipantUIModel = self.selectedParticipantUIModel;

    if (previouslySelectedParticipantUIModel != selectedParticipantUIModel) {
        // Remove the big view from the previous participant's list of renderers
        if (previouslySelectedParticipantUIModel == nil) {
            [self.localMediaController.localVideoTrack removeRenderer:self.largeVideoView];
        } else {
            [previouslySelectedParticipantUIModel.remoteVideoTrack removeRenderer:self.largeVideoView];
        }
    }

    self.selectedParticipantUIModel = selectedParticipantUIModel;

    NSString *identity = nil;
    TVIVideoTrack *videoTrack = nil;

    BOOL shouldMirror = NO;

    if (selectedParticipantUIModel == nil) {
        // We selected the local participant
        identity = @"You";
        videoTrack = self.localMediaController.localVideoTrack;
        shouldMirror = self.localMediaController.shouldMirrorLocalVideoView;
    } else {
        identity = selectedParticipantUIModel.remoteParticipant.identity;
        videoTrack = selectedParticipantUIModel.remoteVideoTrack;
    }

    self.noVideoParticipantLabel.text = identity;

    BOOL videoEnabled = videoTrack.isEnabled;

    for (id <TVIVideoRenderer> renderer in videoTrack.renderers) {
        [videoTrack removeRenderer:renderer];
    }

    [videoTrack addRenderer:self.largeVideoView];

    self.largeVideoView.mirror = shouldMirror;
    self.largeVideoView.hidden = !videoEnabled;
    // Ensure that we can see local and remote camera / screen content.
    self.largeVideoView.contentMode = UIViewContentModeScaleAspectFit;
    self.noVideoParticipantLabel.hidden = videoEnabled;
    self.noVideoImageView.hidden = videoEnabled;

    [self updateRemoteParticipantView:self.selectedParticipantUIModel.remoteParticipant];

    if (videoEnabled && self.selectedParticipantUIModel != nil) {
        self.remoteParticipantLabelView.hidden = NO;
    } else {
        self.remoteParticipantLabelView.hidden = YES;
    }
}

- (void)updateRemoteParticipantView:(TVIParticipant *)participant {
    NSMutableString *initials = [NSMutableString new];
    NSArray *splitItems = [participant.identity componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    for (NSString *item in splitItems) {
        if ([item length] > 0) {
            [initials appendString:[[item substringToIndex:1] uppercaseString]];
        }

        if ([initials length] == 2) {
            break;
        }
    }

    self.remoteParticipantLabel.text = initials;

    if (self.currentDominantSpeaker == participant) {
        self.remoteParticipantMutedStateImage.hidden = YES;
        self.remoteParticipantDominantSpeakerIndicatorImage.hidden = NO;
    } else {
        self.remoteParticipantMutedStateImage.hidden = NO;
        self.remoteParticipantDominantSpeakerIndicatorImage.hidden = YES;
        if ([participant.audioTracks firstObject].track.isEnabled) {
            self.remoteParticipantMutedStateImage.image = [UIImage imageNamed:@"audio-unmuted-white"];
        } else {
            self.remoteParticipantMutedStateImage.image = [UIImage imageNamed:@"audio-muted-white"];
        }
    }

    self.remoteParticipantNetworkQualityIndicator.image = [NetworkQualityIndicator networkQualityIndicatorImageForLevel:participant.networkQualityLevel];
}

- (RemoteParticipantUIModel *)addRemoteParticipantModel:(TVIRemoteParticipant *)participant {
    return [self addRemoteParticipantModel:participant videoTrack:nil];
}

- (RemoteParticipantUIModel *)addRemoteParticipantModel:(TVIRemoteParticipant *)participant
                                             videoTrack:(TVIRemoteVideoTrack *)videoTrack {
    BOOL hasVideo = videoTrack != nil;
    BOOL shouldSelectParticipant = (self.remoteParticipantUIModels.count == 0);

    RemoteParticipantUIModel *addedModel = nil;
    if (!hasVideo && [participant.videoTracks count] == 0) {
        addedModel = [[RemoteParticipantUIModel alloc] initWithRemoteParticipant:participant
                                                                      videoTrack:nil];
    } else if (hasVideo) {
        addedModel = [[RemoteParticipantUIModel alloc] initWithRemoteParticipant:participant
                                                                      videoTrack:videoTrack];
    }

    if (addedModel) {
        [self.remoteParticipantUIModels addObject:addedModel];
        if (shouldSelectParticipant) {
            [self updateVideoUIForSelectedParticipantUIModel:addedModel];
            [self refreshLocalParticipantVideoView];
        } else {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[[self unselectedRemoteModels] count] inSection:0];
            [self.videoCollectionView insertItemsAtIndexPaths:@[indexPath]];
        }
    }

    return addedModel;
}

- (void)deleteParticipantModel:(TVIRemoteParticipant *)participant
                   publication:(TVIRemoteVideoTrack *)videoTrack {
    BOOL clearsSelection = [participant isEqual:self.selectedParticipantUIModel.remoteParticipant] &&
    ((videoTrack == nil) || [self.selectedParticipantUIModel.remoteVideoTrack isEqual:videoTrack]);

    // Remove relevant entries from the model.
    NSIndexSet *indexSet = [self.remoteParticipantUIModels indexesOfObjectsPassingTest:^BOOL(RemoteParticipantUIModel * _Nonnull model,
                                                                                             NSUInteger idx,
                                                                                             BOOL * _Nonnull stop) {
        if ([model.remoteParticipant isEqual:participant]) {
            if (videoTrack == nil) {
                return YES;
            } else if ([model.remoteVideoTrack isEqual:videoTrack]) {
                return YES;
            }
        }
        return NO;
    }];

    NSUInteger selectedIndex = [self.remoteParticipantUIModels indexOfObject:self.selectedParticipantUIModel];
    [self.remoteParticipantUIModels removeObjectsAtIndexes:indexSet];

    // Update the selected UI.
    if (clearsSelection) {
        // Should we try to select another Track from the same Participant?
        // We can't leave the selected model dangling with a stale object, so return to local video.
        [self updateVideoUIForSelectedParticipantUIModel:nil];
        [self refreshLocalParticipantVideoView];
    }

    // Update the collection view cells. We don't consider the selected Participant.
    __block NSMutableArray<NSIndexPath *> *indexPathsToDelete = @[].mutableCopy;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        // Correct indexes after the selected Participant.
        if (idx != selectedIndex) {
            NSUInteger item = idx > selectedIndex ? idx : idx + 1;
            [indexPathsToDelete addObject:[NSIndexPath indexPathForItem:item inSection:0]];
        }
    }];

    if ([indexPathsToDelete count] > 0) {
        [self.videoCollectionView deleteItemsAtIndexPaths:indexPathsToDelete];
    }
}

- (void)rebuildRemoteParticipantUIModels {
    [self.remoteParticipantUIModels removeAllObjects];

    for (TVIRemoteParticipant *participant in self.room.remoteParticipants) {
        if (participant.videoTracks.count == 0) {
            RemoteParticipantUIModel *model = [[RemoteParticipantUIModel alloc] initWithRemoteParticipant:participant
                                                                                               videoTrack:nil];
            [self.remoteParticipantUIModels addObject:model];
        } else {
            for (TVIRemoteVideoTrackPublication *publication in participant.videoTracks) {
                // Wait for subscriptions instead.
                if (publication.remoteTrack) {
                    RemoteParticipantUIModel *model = [[RemoteParticipantUIModel alloc] initWithRemoteParticipant:participant
                                                                                                       videoTrack:publication.remoteTrack];
                    [self.remoteParticipantUIModels addObject:model];
                }
            }
        }
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RemoteParticipantUIModel *previouslySelectedParticipantUIModel = self.selectedParticipantUIModel;

    VideoCollectionViewCell *cell = (VideoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

    if (!([previouslySelectedParticipantUIModel isEqual:cell.remoteParticipantUIModel] ||
          (previouslySelectedParticipantUIModel == nil && cell.remoteParticipantUIModel == nil))) {
        [self updateVideoUIForSelectedParticipantUIModel:cell.remoteParticipantUIModel];
        [self refreshVideoViews];
    }
}

- (NSArray *)unselectedRemoteModels {
    NSMutableArray *exclusiveModels = [NSMutableArray arrayWithArray:self.remoteParticipantUIModels];
    [exclusiveModels removeObject:self.selectedParticipantUIModel];
    return [exclusiveModels copy];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[self unselectedRemoteModels] count] + 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VideoCollectionViewCell *cell = (VideoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"videoCell" forIndexPath:indexPath];

    if (indexPath.row == 0) {
        // 0th element is always the local participant
        [cell setLocalParticipant:self.room.localParticipant isCurrentlySelected:(self.selectedParticipantUIModel == nil)];
    } else {
        RemoteParticipantUIModel *remoteParticipantUIModel = [self unselectedRemoteModels][indexPath.row - 1];
        [cell setRemoteParticipantUIModel:remoteParticipantUIModel isDominantSpeaker:(remoteParticipantUIModel.remoteParticipant == self.currentDominantSpeaker)];
    }

    return cell;
}

#pragma mark - LocalMediaControllerDelegate

- (void)localMediaControllerStartedVideoCapture:(LocalMediaController *)localMediaController {
    if (self.selectedParticipantUIModel == nil) {
        [self updateVideoUIForSelectedParticipantUIModel:nil];
    }

    [self refreshLocalParticipantVideoView];
}

#pragma mark - TVIRoomDelegate

- (void)didConnectToRoom:(TVIRoom *)room {
    NSLog(@"%s - Room sid: %@", __PRETTY_FUNCTION__, room.sid);

    self.joiningLabel.hidden = YES;
    self.joiningRoomLabel.hidden = YES;
    self.recordingWarningLabel.hidden = YES;
    self.recordingIndicator.hidden = !(room.isRecording);
    self.mainLabel.text = self.roomName;

    self.localMediaController.localParticipant = self.room.localParticipant;
    self.localMediaController.localParticipant.delegate = self;

    for (TVIRemoteParticipant *participant in room.remoteParticipants) {
        participant.delegate = self;
    }

    self.statsViewController.room = room;

    [self rebuildRemoteParticipantUIModels];

    // Select the screen Track automatically?
    RemoteParticipantUIModel *model = [self.remoteParticipantUIModels firstObject];
    if (model) {
        [self updateVideoUIForSelectedParticipantUIModel:model];
    }

    self.videoCollectionView.hidden = NO;
    [self refreshVideoViews];
    [self setNeedsUpdateOfHomeIndicatorAutoHidden];
}

- (void)room:(TVIRoom *)room didFailToConnectWithError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self handleRoomError:error onConnect:YES];
    self.room = nil;
    [self setNeedsUpdateOfHomeIndicatorAutoHidden];
}

- (void)room:(TVIRoom *)room didDisconnectWithError:(NSError *)error {
    NSLog(@"%s - Room sid: %@", __PRETTY_FUNCTION__, room.sid);

    self.localMediaController.localParticipant = nil;
    self.statsViewController.room = nil;

    self.room = nil;
    [self setNeedsUpdateOfHomeIndicatorAutoHidden];

    if (error) {
        [self handleRoomError:error onConnect:NO];
    } else {
        [self dismissViewController];
    }
}

- (void)room:(TVIRoom *)room isReconnectingWithError:(NSError *)error {
    NSLog(@"%s - Room sid: %@ Reason: %@",
          __PRETTY_FUNCTION__,
          room.sid,
          error.localizedDescription);
}

- (void)didReconnectToRoom:(TVIRoom *)room {
    NSLog(@"%s - Room sid: %@", __PRETTY_FUNCTION__, room.sid);
}

- (void)room:(TVIRoom *)room participantDidConnect:(TVIRemoteParticipant *)participant {
    NSLog(@"%s - Room sid: %@ Identity: %@ Participant sid: %@",
          __PRETTY_FUNCTION__,
          room.sid,
          participant.identity,
          participant.sid);
    participant.delegate = self;

    [self addRemoteParticipantModel:participant];
}

- (void)room:(TVIRoom *)room participantDidDisconnect:(TVIRemoteParticipant *)participant {
    NSLog(@"%s - Room sid: %@ Identity: %@ Participant sid: %@",
          __PRETTY_FUNCTION__,
          room.sid,
          participant.identity,
          participant.sid);

    [self deleteParticipantModel:participant publication:nil];
}

- (void)roomDidStartRecording:(TVIRoom *)room {
    self.recordingIndicator.hidden = NO;
}

- (void)roomDidStopRecording:(TVIRoom *)room {
    self.recordingIndicator.hidden = YES;
}

- (void)room:(TVIRoom *)room dominantSpeakerDidChange:(TVIRemoteParticipant *)participant {
    NSLog(@"%s", __PRETTY_FUNCTION__);

    TVIRemoteParticipant *previousDominantSpeaker = self.currentDominantSpeaker;
    self.currentDominantSpeaker = participant;

    // Remove indicator from previous dominant speaker if necessary
    if (previousDominantSpeaker != nil) {
        if ([self.selectedParticipantUIModel.remoteParticipant isEqual:previousDominantSpeaker]) {
            [self updateRemoteParticipantView:previousDominantSpeaker];
        } else {
            [self refreshParticipantVideoViews:previousDominantSpeaker];
        }
    }

    // Add indicator for current dominant speaker if necessary
    if (self.currentDominantSpeaker != nil) {
        if ([self.selectedParticipantUIModel.remoteParticipant isEqual:self.currentDominantSpeaker]) {
            [self updateRemoteParticipantView:self.currentDominantSpeaker];
        } else {
            [self refreshParticipantVideoViews:self.currentDominantSpeaker];
        }
    }
}

#pragma mark - TVIRemoteParticipantDelegate

- (void)remoteParticipant:(TVIRemoteParticipant *)participant didPublishAudioTrack:(TVIRemoteAudioTrackPublication *)publication {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)remoteParticipant:(TVIRemoteParticipant *)participant didUnpublishAudioTrack:(TVIRemoteAudioTrackPublication *)publication {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)remoteParticipant:(TVIRemoteParticipant *)participant didPublishVideoTrack:(TVIRemoteVideoTrackPublication *)publication {
    NSLog(@"%s", __PRETTY_FUNCTION__);

    // Delete the existing model, expecting that we will subscribe to a published Track instead.
    if ([participant.remoteVideoTracks count] == 1) {
        [self deleteParticipantModel:participant publication:nil];
    }
}

- (void)remoteParticipant:(TVIRemoteParticipant *)participant didUnpublishVideoTrack:(TVIRemoteVideoTrackPublication *)publication {
    NSLog(@"%s", __PRETTY_FUNCTION__);

    if ([participant.remoteVideoTracks count] == 0) {
        [self addRemoteParticipantModel:participant];
    }
}

- (void)remoteParticipant:(TVIRemoteParticipant *)participant didPublishDataTrack:(TVIRemoteDataTrackPublication *)publication {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)remoteParticipant:(TVIRemoteParticipant *)participant didUnpublishDataTrack:(TVIRemoteDataTrackPublication *)publication {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)didSubscribeToAudioTrack:(TVIRemoteAudioTrack *)audioTrack
                     publication:(TVIRemoteAudioTrackPublication *)publication
                  forParticipant:(TVIRemoteParticipant *)participant {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if ([self.selectedParticipantUIModel.remoteParticipant isEqual:participant]) {
        [self updateRemoteParticipantView:participant];
    }
    
    [self refreshParticipantVideoViews:participant];
}

- (void)didUnsubscribeFromAudioTrack:(TVIRemoteAudioTrack *)audioTrack
                         publication:(TVIRemoteAudioTrackPublication *)publication
                      forParticipant:(TVIRemoteParticipant *)participant {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if ([self.selectedParticipantUIModel.remoteParticipant isEqual:participant]) {
        [self updateRemoteParticipantView:participant];
    }
    
    [self refreshParticipantVideoViews:participant];
}

- (void)didSubscribeToVideoTrack:(TVIRemoteVideoTrack *)videoTrack
                     publication:(TVIRemoteVideoTrackPublication *)publication
                  forParticipant:(TVIRemoteParticipant *)participant {
    NSLog(@"%s", __PRETTY_FUNCTION__);

    [self addRemoteParticipantModel:participant videoTrack:videoTrack];
}

- (void)didUnsubscribeFromVideoTrack:(TVIRemoteVideoTrack *)videoTrack
                         publication:(TVIRemoteVideoTrackPublication *)publication
                      forParticipant:(TVIRemoteParticipant *)participant {
    NSLog(@"%s", __PRETTY_FUNCTION__);

    [self deleteParticipantModel:participant publication:videoTrack];
}

- (void)didSubscribeToDataTrack:(TVIRemoteDataTrack *)dataTrack
                    publication:(TVIRemoteDataTrackPublication *)publication
                 forParticipant:(TVIRemoteParticipant *)participant {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)didUnsubscribeFromDataTrack:(TVIRemoteDataTrack *)dataTrack
                        publication:(TVIRemoteDataTrackPublication *)publication
                     forParticipant:(TVIRemoteParticipant *)participant {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)remoteParticipant:(TVIRemoteParticipant *)participant didEnableAudioTrack:(TVIRemoteAudioTrackPublication *)publication {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if ([self.selectedParticipantUIModel.remoteParticipant isEqual:participant]) {
        [self updateRemoteParticipantView:self.selectedParticipantUIModel.remoteParticipant];
    }
    [self refreshParticipantVideoViews:participant];
}

- (void)remoteParticipant:(TVIRemoteParticipant *)participant didDisableAudioTrack:(TVIRemoteAudioTrackPublication *)publication {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if ([self.selectedParticipantUIModel.remoteParticipant isEqual:participant]) {
        [self updateRemoteParticipantView:self.selectedParticipantUIModel.remoteParticipant];
    }
    [self refreshParticipantVideoViews:participant];
}

- (void)remoteParticipant:(TVIRemoteParticipant *)participant didEnableVideoTrack:(TVIRemoteVideoTrackPublication *)publication {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if ([self.selectedParticipantUIModel.remoteParticipant isEqual:participant]) {
        [self updateVideoUIForSelectedParticipantUIModel:self.selectedParticipantUIModel];
    }
    [self refreshParticipantVideoViews:participant];
}

- (void)remoteParticipant:(TVIRemoteParticipant *)participant didDisableVideoTrack:(TVIRemoteVideoTrackPublication *)publication {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if ([self.selectedParticipantUIModel.remoteParticipant isEqual:participant]) {
        [self updateVideoUIForSelectedParticipantUIModel:self.selectedParticipantUIModel];
    }
    [self refreshParticipantVideoViews:participant];
}

- (void)remoteParticipant:(TVIRemoteParticipant *)participant networkQualityLevelDidChange:(TVINetworkQualityLevel)networkQualityLevel {
    if ([participant isEqual:self.selectedParticipantUIModel.remoteParticipant]) {
        [self updateRemoteParticipantView:participant];
    } else {
        NSUInteger index = [[self unselectedRemoteModels] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [participant isEqual:((RemoteParticipantUIModel *)obj).remoteParticipant];
        }];

        if (index != NSNotFound) {
            NSInteger row = index + 1; // Add 1 for local participant at index 0
            VideoCollectionViewCell *cell = (VideoCollectionViewCell *)[self.videoCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
            cell.networkQualityLevel = networkQualityLevel;
        }
    }
}

#pragma mark - TVILocalParticipantDelegate

- (void)localParticipant:(TVILocalParticipant *)participant didPublishVideoTrack:(TVILocalVideoTrackPublication *)publishedVideoTrack {
    [self refreshLocalParticipantVideoView];
}

- (void)localParticipant:(TVILocalParticipant *)participant didFailToPublishVideoTrack:(TVILocalVideoTrack *)videoTrack withError:(NSError *)error {
    NSLog(@"Failed to publish video track with error %@", error);
    [self refreshLocalParticipantVideoView];
}

- (void)localParticipant:(TVILocalParticipant *)participant didPublishAudioTrack:(TVILocalAudioTrackPublication *)publishedAudioTrack {
    [self refreshLocalParticipantVideoView];
}

- (void)localParticipant:(TVILocalParticipant *)participant didFailToPublishAudioTrack:(TVILocalAudioTrack *)audioTrack withError:(NSError *)error {
    NSLog(@"Failed to publish audio track with error %@", error);
    [self refreshLocalParticipantVideoView];
}

- (void)localParticipant:(TVILocalParticipant *)participant networkQualityLevelDidChange:(TVINetworkQualityLevel)networkQualityLevel {
    NSLog(@"Network Quality Level for LocalParticipant: %zd", networkQualityLevel);

    VideoCollectionViewCell *cell = (VideoCollectionViewCell *)[self.videoCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.networkQualityLevel = networkQualityLevel;
}

@end
