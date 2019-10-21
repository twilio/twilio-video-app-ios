//
//  StatsViewController.m
//  VideoApp
//
//  Created by Ryan Payne on 3/16/17.
//  Copyright © 2017 Twilio, Inc. All rights reserved.
//

#import "StatsViewController.h"
#import "SettingsKeyConstants.h"
#import "StatsUIModel.h"

#import "HeaderTableViewCell.h"
#import "TrackStatsTableViewCell.h"

static const CGFloat kGapWidth = 0.15;
static const CGFloat kAnimationDuration = 0.35;

@interface StatsViewController ()

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

@property (nonatomic, strong) NSArray<StatsUIModel *> *statsUIModels;
@end

@implementation StatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.55];

    self.grayView = [[UIView alloc] init];
    self.grayView.backgroundColor = [UIColor grayColor];

    self.swipeGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    self.swipeGestureRecognizer.edges = UIRectEdgeRight;

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

    self.statCollectionEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsEnableStatsCollectionKey];

    [self displayStatsUnavailableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        // RCP: This sucks... You get a noticable flicker when these are applied..
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
                     }];
}

@end
