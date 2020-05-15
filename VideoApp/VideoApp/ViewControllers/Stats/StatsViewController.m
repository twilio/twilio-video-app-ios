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

#import "StatsViewController.h"

#import <mach/mach.h>
#import <mach/processor_info.h>
#import <mach/mach_host.h>
#import <TwilioVideo/TwilioVideo.h>

#import "HeaderTableViewCell.h"
#import "StatsUIModel.h"
#import "TrackStatsTableViewCell.h"
#import "VideoApp-Swift.h"

static const CGFloat kGapWidth = 0.15;
static const CGFloat kAnimationDuration = 0.35;
static const NSTimeInterval kStatsTimerInterval = 2.0;

@interface StatsViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, assign, getter=isStatsViewDisplayed) BOOL statsViewDisplayed;

@property (nonatomic, assign, getter=isStatCollectionEnabled) BOOL statCollectionEnabled;
@property (nonatomic, strong) IBOutlet UIView *disabledView;
@property (nonatomic, weak) IBOutlet UILabel *disabledViewLabel1;
@property (nonatomic, weak) IBOutlet UILabel *disabledViewLable2;
@property (nonatomic, strong) NSLayoutConstraint *disabledViewXConstraint;
@property (nonatomic, strong) NSLayoutConstraint *disabledViewYConstraint;

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *swipeGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic, strong) NSLayoutConstraint *leftConstraint;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;

@property (nonatomic, strong) UIView *grayView;

@property (nonatomic, strong) NSTimer *statsTimer;
@property (nonatomic, strong) NSOperationQueue *statsProcessingQueue;
@property (nonatomic, strong) NSArray<StatsUIModel *> *statsUIModels;

@property (nonatomic, assign, readonly) processor_info_array_t lastCpuInfo;
@property (nonatomic, assign, readonly) mach_msg_type_number_t lastCpuInfoSize;
@property (nonatomic, assign) NSProcessInfoThermalState lastThermalState;
@property (nonatomic, strong) TVIIceCandidatePairStats *lastPairStats;
@property (nonatomic, strong) NSDate *lastPairDate;
@property (nonatomic, strong) TVIRoom *room;

@end

@implementation StatsViewController

@synthesize room = _room;

- (void)setRoom:(TVIRoom *)room {
    if (room == _room) {
        return;
    }
    _room = room;

    if (self.statsTimer != nil) {
        [self.statsTimer invalidate];
        self.statsTimer = nil;
    }

    if (room) {
        self.statsProcessingQueue = [[NSOperationQueue alloc] init];
        self.statsProcessingQueue.maxConcurrentOperationCount = 1;
        if (_statsViewDisplayed) {
            self.statsTimer = [NSTimer timerWithTimeInterval:kStatsTimerInterval target:self selector:@selector(statsTimerFired) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.statsTimer forMode:NSRunLoopCommonModes];
            [self.statsTimer fire];
        }
    } else {
        [self.statsProcessingQueue cancelAllOperations];
        self.statsProcessingQueue = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.55];

    self.grayView = [[UIView alloc] init];
    self.grayView.backgroundColor = [UIColor grayColor];

    self.swipeGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    self.swipeGestureRecognizer.edges = UIRectEdgeRight;
    self.swipeGestureRecognizer.delegate = self;

    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    self.panGestureRecognizer.enabled = NO;

    // Configure the disabled view stuffs
    self.disabledView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0];
    self.disabledView.translatesAutoresizingMaskIntoConstraints = NO;

    self.disabledViewXConstraint = [NSLayoutConstraint constraintWithItem:self.disabledView
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.view
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1.0
                                                                 constant:0];
    self.disabledViewYConstraint = [NSLayoutConstraint constraintWithItem:self.disabledView
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.view
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1.0
                                                                 constant:-(self.disabledView.frame.size.height / 2)];

    self.statCollectionEnabled = YES;

    [self displayStatsUnavailableView];

    self.lastThermalState = NSProcessInfoThermalStateNominal;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(thermalStateDidChange:)
                                                 name:NSProcessInfoThermalStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(roomDidChange)
                                                 name:@"RoomDidChange"
                                               object:nil];
}

- (void)dealloc {
    if (_lastCpuInfo) {
        vm_deallocate(mach_task_self(), (vm_address_t)_lastCpuInfo, _lastCpuInfoSize);
        _lastCpuInfo = NULL;
        _lastCpuInfoSize = 0;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addAsSwipeableViewToParentViewController:(UIViewController *)parentViewController {
    if (parentViewController != nil) {
        UIView *parentView = parentViewController.view;

        [parentView addSubview:self.view];
        [parentView addGestureRecognizer:self.swipeGestureRecognizer];
        [parentView addGestureRecognizer:self.panGestureRecognizer];

        [parentViewController.navigationController.barHideOnSwipeGestureRecognizer addTarget:self action:@selector(navBarHiddenHandler:)];
        [parentViewController.navigationController.barHideOnTapGestureRecognizer addTarget:self action:@selector(navBarHiddenHandler:)];

        // Configure layout constraints for the stats view
        self.view.translatesAutoresizingMaskIntoConstraints = NO;
        self.widthConstraint = [self.view.widthAnchor constraintEqualToAnchor:parentView.widthAnchor constant:-(parentView.frame.size.width * kGapWidth)];
        self.leftConstraint = [self.view.leftAnchor constraintEqualToAnchor:parentView.leftAnchor constant:parentView.frame.size.width];
        self.heightConstraint = [self.view.heightAnchor constraintEqualToAnchor:parentView.heightAnchor];
        self.bottomConstraint = [self.view.bottomAnchor constraintEqualToAnchor:parentView.bottomAnchor];

        NSArray *layoutConstraints = @[ self.widthConstraint,
                                        self.heightConstraint,
                                        self.leftConstraint,
                                        self.bottomConstraint ];

        [NSLayoutConstraint activateConstraints:layoutConstraints];
        [parentViewController addChildViewController:self];
        [self didMoveToParentViewController:parentViewController];

        [self adjustConstraintsForNavBar:NO];
        [self adjustConstraintsForStatusBar:NO];
    }
}

- (void)roomDidChange {
    self.room = ((Room *)self.videoAppRoom).room;
}

- (void)removeStatsUnavailableView {
    [NSLayoutConstraint deactivateConstraints:@[ self.disabledViewXConstraint, self.disabledViewYConstraint ]];
    [self.disabledView removeFromSuperview];
}

- (void)displayStatsUnavailableView {
    if ([self.view.subviews containsObject:self.disabledView]) {
        return;
    }

    if (self.isStatCollectionEnabled) {
        self.disabledViewLabel1.text = @"Statistics Unavailable";
        self.disabledViewLable2.text = @"Media is Not Being Shared";
    } else {
        self.disabledViewLabel1.text = @"Statistics Gathering Disabled";
        self.disabledViewLable2.text = @"Enable in Settings";
    }

    [self.view addSubview:self.disabledView];
    [NSLayoutConstraint activateConstraints:@[ self.disabledViewXConstraint, self.disabledViewYConstraint ]];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (self.isStatsViewDisplayed) {
        self.leftConstraint.constant = size.width * kGapWidth;
    } else {
        self.leftConstraint.constant = size.width;
    }

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        // You get a noticable flicker when these are applied.
        // But because they way they currently are calculated, the values necessary are only
        // known after the rotation has completed. Still looking for a better solution, but this
        // gets more accurate handling for rotation than we had prior.
        [self adjustConstraintsForStatusBar:YES];
        [self adjustConstraintsForNavBar:YES];
    }];

    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)navBarHiddenHandler:(id)sender {
    if ([sender isKindOfClass:[UIGestureRecognizer class]] &&
        ((UIGestureRecognizer *)sender).state != UIGestureRecognizerStateEnded) {
        return;
    }

    [self adjustConstraintsForNavBar:YES];
}

- (void)adjustConstraintsForNavBar:(BOOL)shouldAnimate {
    if (self.parentViewController.navigationController.isNavigationBarHidden) {
        self.heightConstraint.constant = 0;
    } else {
        self.heightConstraint.constant = -(self.parentViewController.navigationController.navigationBar.frame.size.height);
    }

    if (shouldAnimate) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            [self.parentViewController.view layoutIfNeeded];
        }];
    }
}

- (void)adjustConstraintsForStatusBar:(BOOL)shouldAnimate {
    CGFloat statusBarHeight = [UIApplication sharedApplication].isStatusBarHidden ? 0 : [UIApplication sharedApplication].statusBarFrame.size.height;
    [self.tableView setContentInset:UIEdgeInsetsMake(statusBarHeight, 0, 0, 0)];

    if (shouldAnimate) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)updateStatsUIWithModels:(NSArray<StatsUIModel *> *)statsUIModels {
    if (statsUIModels == nil && self.statsUIModels == nil) {
        return;
    }

    typeof(self) __weak weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        typeof(self) __strong strongSelf = weakSelf;

        if (strongSelf) {
            strongSelf.statsUIModels = statsUIModels;
            [strongSelf refresh];
        }
    });
}

- (void)refresh {
    if (self.statsUIModels == nil || [self.statsUIModels count] == 0) {
        [self.tableView reloadData];
        [self displayStatsUnavailableView];
    } else {
        [self removeStatsUnavailableView];
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.statsUIModels[section].attributeCount + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        HeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
        cell.title.text = self.statsUIModels[indexPath.section].title;
        return cell;
    } else {
        TrackStatsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrackStatsCell"];

        cell.titleLabel.text = [self.statsUIModels[indexPath.section] titleForAttributeIndex:indexPath.row - 1];
        cell.valueLabel.text = [self.statsUIModels[indexPath.section] valueForAttributeIndex:indexPath.row - 1];
        
        return cell;
    }

    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.statsUIModels count];
}

#pragma mark - UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 44.0;
    } else {
        return 22.0;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - Gesture Recognizer actions

- (void)swipe:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer {
    UIView *parentView = self.parentViewController.view;

    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.grayView.alpha = 0.0;
            [parentView insertSubview:self.grayView belowSubview:self.view];
            [self applyFullConstraintsToView:self.grayView];
            break;
        case UIGestureRecognizerStateChanged:
            [self moveWithPoint:[gestureRecognizer translationInView:parentView]];
            [gestureRecognizer setTranslation:CGPointZero inView:parentView];
            break;
        case UIGestureRecognizerStateEnded:
            if ([gestureRecognizer velocityInView:parentView].x > 0) {
                [self parentViewDisplayed];
            } else {
                [self statsViewDisplayed];
            }
            break;
        default:
            break;
    }
}

- (void)pan:(UIPanGestureRecognizer *)gestureRecognizer {
    UIView *parentView = self.parentViewController.view;

    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateChanged:
            [self moveWithPoint:[gestureRecognizer translationInView:parentView]];
            [gestureRecognizer setTranslation:CGPointZero inView:parentView];
            break;
        case UIGestureRecognizerStateEnded:
            if ([gestureRecognizer velocityInView:parentView].x < 0) {
                [self statsViewDisplayed];
            } else {
                [self parentViewDisplayed];
            }
            break;
        default:
            break;
    }
}

- (void)applyFullConstraintsToView:(UIView *)view {
    view.translatesAutoresizingMaskIntoConstraints = NO;

    UIView *parentView = self.parentViewController.view;

    NSArray *layoutConstraints = @[ [view.leftAnchor constraintEqualToAnchor:parentView.leftAnchor],
                                    [view.rightAnchor constraintEqualToAnchor:parentView.rightAnchor],
                                    [view.topAnchor constraintEqualToAnchor:parentView.topAnchor],
                                    [view.bottomAnchor constraintEqualToAnchor:parentView.bottomAnchor] ];

    [NSLayoutConstraint activateConstraints:layoutConstraints];
}

- (void)moveWithPoint:(CGPoint)point {
    UIView *parentView = self.parentViewController.view;
    UIView *topView = self.view;

    CGFloat gap = parentView.frame.size.width * kGapWidth;

    if (topView != nil) {
        CGPoint center = topView.center;
        center.x = MIN(MAX(topView.center.x + point.x, parentView.center.x + gap), parentView.frame.size.width + topView.frame.size.width / 2);
        topView.center = center;
        CGFloat alpha = ((parentView.frame.origin.x + gap) - (topView.frame.origin.x)) / (parentView.frame.size.width - gap);
        self.grayView.alpha = (alpha + 1) * 0.75;
    }
}

- (void)statsViewDisplayed {
    UIView *parentView = self.parentViewController.view;

    self.leftConstraint.constant = parentView.frame.size.width * kGapWidth;
    CGRect frame = self.view.frame;
    frame.origin.x = self.leftConstraint.constant;

    if (self.statsTimer == nil) {
        self.statsTimer = [NSTimer timerWithTimeInterval:kStatsTimerInterval target:self selector:@selector(statsTimerFired) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.statsTimer forMode:NSRunLoopCommonModes];
        [self.statsTimer fire];
    }

    [UIView animateWithDuration:kAnimationDuration
                     animations:^{
                         self.view.frame = frame;
                         self.grayView.alpha = 0.75;
                         [parentView layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         self.parentViewController.navigationController.hidesBarsOnSwipe = NO;
                         self.panGestureRecognizer.enabled = YES;
                         self.statsViewDisplayed = YES;
                     }];
}

- (void)parentViewDisplayed {
    UIView *parentView = self.parentViewController.view;

    self.leftConstraint.constant = parentView.frame.size.width;
    CGRect frame = self.view.frame;
    frame.origin.x = self.leftConstraint.constant;

    [UIView animateWithDuration:kAnimationDuration
                     animations:^{
                         self.view.frame = frame;
                         self.grayView.alpha = 0.0;
                         [parentView layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         [self.grayView removeFromSuperview];
                         self.parentViewController.navigationController.hidesBarsOnSwipe = YES;
                         self.panGestureRecognizer.enabled = NO;
                         self.statsViewDisplayed = NO;
                         [self.statsTimer invalidate];
                         self.statsTimer = nil;
                     }];
}

#pragma mark - Stats

- (void)thermalStateDidChange:(NSNotification *)note {
    NSProcessInfoThermalState state = NSProcessInfo.processInfo.thermalState;
    [self.statsProcessingQueue addOperationWithBlock:^{
        self.lastThermalState = state;
    }];
}

- (void)statsTimerFired {
    typeof(self) __weak weakSelf = self;

    [self.room getStatsWithBlock:^(NSArray<TVIStatsReport *> * _Nonnull statsReports) {
        [weakSelf.statsProcessingQueue addOperationWithBlock:^{
            typeof(self) __strong strongSelf = weakSelf;

            if (strongSelf) {
                [strongSelf processStatsReports:statsReports];
            }
        }];
    }];
}

- (void)processStatsReports:(NSArray<TVIStatsReport *> *)statsReports {
    if ([statsReports count] == 0) {
        [self updateStatsUIWithModels:nil];
        return;
    }

    NSMutableArray<StatsUIModel *> *statsUIModels = [NSMutableArray new];
    BOOL haveProcessedLocalTracks = NO;
    NSInteger trackCount;

    StatsUIModel *regions = [[StatsUIModel alloc] initWithSignalingRegion:self.room.localParticipant.signalingRegion
                                                              mediaRegion:self.room.mediaRegion];
    [statsUIModels addObject:regions];

    for (TVIStatsReport *statsReport in statsReports) {
        if (!haveProcessedLocalTracks) {
            // Only get local tracks from the first stats report at this time
            if ([statsReport.localAudioTrackStats count] > 0 || [statsReport.localVideoTrackStats count] > 0) {
                haveProcessedLocalTracks = YES;
            }

            trackCount = 1;
            for (TVILocalAudioTrackStats *localAudioTrackStats in statsReport.localAudioTrackStats) {
                NSString *trackName = @"Local Audio Track";

                if ([statsReport.localVideoTrackStats count] > 1) {
                    trackName = [trackName stringByAppendingFormat:@" %zd", trackCount];
                    trackCount++;
                }

                StatsUIModel *statsUIModel = [[StatsUIModel alloc] initWithLocalAudioTrackStats:localAudioTrackStats trackName:trackName];
                [statsUIModels addObject:statsUIModel];
            }

            trackCount = 1;
            for (TVILocalVideoTrackStats *localVideoTrackStats in statsReport.localVideoTrackStats) {
                // RCP: Todo: Figure out a way to tell whether local video tracks are camera or screen capture...
                NSString *trackName = @"Local Video Track";

                if ([statsReport.localVideoTrackStats count] > 1) {
                    trackName = [trackName stringByAppendingFormat:@" %zd", trackCount];
                    trackCount++;
                }

                StatsUIModel *statsUIModel = [[StatsUIModel alloc] initWithLocalVideoTrackStats:localVideoTrackStats trackName:trackName];
                [statsUIModels addObject:statsUIModel];
            }
        }

        NSUInteger activePairs = 0;
        for (TVIIceCandidatePairStats *pairStats in statsReport.iceCandidatePairStats) {
            NSString *connectionId = activePairs == 0 ? @"Peer Connection" : statsReport.peerConnectionId;

            if (pairStats.isActiveCandidatePair) {
                activePairs++;

                TVIIceCandidateStats *localCandidate = nil;
                TVIIceCandidateStats *remoteCandidate = nil;
                for (TVIIceCandidateStats *candidateStats in statsReport.iceCandidateStats) {
                    if (candidateStats.isRemote && [candidateStats.transportId isEqualToString:pairStats.remoteCandidateId]) {
                        remoteCandidate = candidateStats;
                    } else if (!candidateStats.isRemote && [candidateStats.transportId isEqualToString:pairStats.localCandidateId]) {
                        localCandidate = candidateStats;
                    }

                    if (localCandidate && remoteCandidate) {
                        break;
                    }
                }
                StatsUIModel *statsUIModel = [[StatsUIModel alloc] initWithIceCandidatePairStats:pairStats
                                                                                  localCandidate:localCandidate
                                                                                 remoteCandidate:remoteCandidate
                                                                                   lastPairStats:self.lastPairStats
                                                                                        lastDate:self.lastPairDate
                                                                                    connectionId:connectionId];
                self.lastPairStats = pairStats;
                self.lastPairDate = [NSDate date];
                [statsUIModels addObject:statsUIModel];
            }
        }

        NSArray *participants = self.room.remoteParticipants;

        for (TVIRemoteAudioTrackStats *remoteAudioTrackStats in statsReport.remoteAudioTrackStats) {
            NSString *trackName = [self trackNameForTrackSid:remoteAudioTrackStats.trackSid participants:participants];
            StatsUIModel *statsUIModel = [[StatsUIModel alloc] initWithRemoteAudioTrackStats:remoteAudioTrackStats trackName:trackName];
            [statsUIModels addObject:statsUIModel];
        }

        for (TVIRemoteVideoTrackStats *remoteVideoTrackStats in statsReport.remoteVideoTrackStats) {
            NSString *trackName = [self trackNameForTrackSid:remoteVideoTrackStats.trackSid participants:participants];
            StatsUIModel *statsUIModel = [[StatsUIModel alloc] initWithRemoteVideoTrackStats:remoteVideoTrackStats trackName:trackName];
            [statsUIModels addObject:statsUIModel];
        }
    }

    NSArray *cpuAverages = [self measureCPUUsage];
    StatsUIModel *processStatsModel = [[StatsUIModel alloc] initWithThermalState:self.lastThermalState
                                                                     cpuAverages:cpuAverages];
    [statsUIModels addObject:processStatsModel];

    [statsUIModels sortUsingComparator:^NSComparisonResult(StatsUIModel *obj1, StatsUIModel *obj2) {
        if (obj1.isLocalTrack) {
            if (!obj2.isLocalTrack) {
                return NSOrderedAscending;
            } else {
                return [obj1.title caseInsensitiveCompare:obj2.title];
            }
        } else {
            return [obj1.title caseInsensitiveCompare:obj2.title];
        }
    }];

    [self updateStatsUIWithModels:statsUIModels];
}

- (NSString *)trackNameForTrackSid:(NSString *)trackSid participants:(NSArray<TVIRemoteParticipant *> *)participants {
    for (TVIParticipant *participant in participants) {
        NSInteger trackCount;

        trackCount = 1;
        NSArray<TVIVideoTrackPublication *> *videoTrackPublications = [participant videoTracks];
        for (TVIVideoTrackPublication *publication in videoTrackPublications) {
            if ([publication.trackSid isEqualToString:trackSid]) {
                return [NSString stringWithFormat:@"%@ Video Track %@",
                        participant.identity,
                        videoTrackPublications.count > 1 ? @(trackCount) : @""];
            }
            trackCount ++;
        }

        trackCount = 1;
        NSArray<TVIAudioTrackPublication *> *audioTrackPublications = [participant audioTracks];
        for (TVIAudioTrackPublication *publication in audioTrackPublications) {
            if ([publication.trackSid isEqualToString:trackSid]) {
                return [NSString stringWithFormat:@"%@ Audio Track %@",
                        participant.identity,
                        audioTrackPublications.count > 1 ? @(trackCount) : @""];
            }
            trackCount ++;
        }
    }

    return @"";
}

- (NSArray<NSNumber *> *)measureCPUUsage {
    natural_t numCPUsU = 0U;
    mach_msg_type_number_t numCpuInfo;
    processor_info_array_t cpuInfo;
    // On iOS devices specifying PROCESSOR_TEMPERATURE or PROCESSOR_PM_REGS_INFO results in a KERN_FAILURE error.
    kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuInfo, &numCpuInfo);
    if (err != KERN_SUCCESS) {
        return @[];
    }
    NSMutableArray *averageUsage = [NSMutableArray array];
    for (unsigned i = 0U; i < numCPUsU; ++i) {
        integer_t inUse, total;
        float percentUsage;
        unsigned index = CPU_STATE_MAX * i;
        if (_lastCpuInfo) {
            integer_t user = cpuInfo[index + CPU_STATE_USER] - _lastCpuInfo[index + CPU_STATE_USER];
            integer_t system = cpuInfo[index + CPU_STATE_SYSTEM] - _lastCpuInfo[index + CPU_STATE_SYSTEM];
            integer_t nice = cpuInfo[index + CPU_STATE_NICE] - _lastCpuInfo[index + CPU_STATE_NICE];
            integer_t idle = cpuInfo[index + CPU_STATE_IDLE] - _lastCpuInfo[index + CPU_STATE_IDLE];

            inUse = user + system + nice;
            total = inUse + idle;
            percentUsage = (float)inUse / (float)total;
            [averageUsage addObject:@(percentUsage)];
        }
    }

    if (_lastCpuInfo) {
        vm_deallocate(mach_task_self(), (vm_address_t)_lastCpuInfo, _lastCpuInfoSize);
    }
    _lastCpuInfo = cpuInfo;
    _lastCpuInfoSize = sizeof(integer_t) * numCpuInfo;
    return [averageUsage copy];
}

@end
