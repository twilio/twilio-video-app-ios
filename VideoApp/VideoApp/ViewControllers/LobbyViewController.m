//
//  LobbyViewController.m
//  VideoApp
//
//  Created by Ryan Payne on 1/23/17.
//  Copyright © 2017 Twilio, Inc. All rights reserved.
//

#import "LobbyViewController.h"
#import "TwilioVideoAppAPI.h"
#import "SettingsKeyConstants.h"
#import "LocalMediaController.h"
#import "RoomViewController.h"
#import "VariableAlphaToggleButton.h"
#import "VideoApp-Swift.h"
@import TwilioVideo;

@interface LobbyViewController () <LocalMediaControllerDelegate>
@property (nonatomic, weak) IBOutlet UILabel *loggedInUser;
@property (nonatomic, weak) IBOutlet TVIVideoView *localVideoView;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UILabel *youLabel;
@property (nonatomic, weak) IBOutlet UIImageView *noVideoImage;

@property (nonatomic, weak) IBOutlet UITextField *roomTextField;
@property (nonatomic, weak) IBOutlet VariableAlphaToggleButton *audioToggleButton;
@property (nonatomic, weak) IBOutlet VariableAlphaToggleButton *videoToggleButton;
@property (nonatomic, weak) IBOutlet UIButton *settingsButton;
@property (nonatomic, weak) IBOutlet UIButton *flipCameraButton;

@property (nonatomic, weak) RoomViewController *roomViewController;

@property (nonatomic, strong) LocalMediaController *localMediaController;

@end

@implementation LobbyViewController

- (BOOL)isModalInPresentation {
    // Swiping to dismiss the LobbyViewController is not desirable. Use the logout action instead.
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Tweak up the UI
    self.roomTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Room"
                                                                               attributes:@{ NSForegroundColorAttributeName: [UIColor lightGrayColor] }];

    [self.roomTextField addTarget:self
                           action:@selector(joinRoomButtonPressed:)
                 forControlEvents:UIControlEventEditingDidEndOnExit];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:tap];

    // Make sure the video and container views are still at the back of the stack... They're being... Difficult...
    [self.view sendSubviewToBack:self.containerView];
    [self.view sendSubviewToBack:self.localVideoView];

    self.localMediaController = [LocalMediaController new];
    [self.localMediaController addDelegate:self];
    [self.localMediaController createLocalAudioTrack];
    [self.localMediaController createLocalVideoTrack];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.loggedInUser.text = AuthStore.shared.userDisplayName;
    self.audioToggleButton.selected = !self.localMediaController.localAudioTrack;
    self.videoToggleButton.selected = !self.localMediaController.localVideoTrack;
    [self updateVideoUI:!self.localMediaController.localVideoTrack];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.localMediaController.localVideoTrack removeRenderer:self.localVideoView];

    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
    CGFloat height = guide.layoutFrame.origin.y + 108;
    self.containerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), height);
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    [self.view setNeedsLayout];
}

- (void)updateVideoUI:(BOOL)isMuted {
    if (isMuted) {
        self.localVideoView.hidden = YES;
        self.youLabel.hidden = NO;
        self.noVideoImage.hidden = NO;
        [self.localMediaController.localVideoTrack removeRenderer:self.localVideoView];
    } else {
        if (![self.localMediaController.localVideoTrack.renderers containsObject:self.localVideoView]) {
            [self.localMediaController.localVideoTrack addRenderer:self.localVideoView];
            self.localVideoView.mirror = self.localMediaController.shouldMirrorLocalVideoView;
        }
    }

    self.flipCameraButton.enabled = !isMuted;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)toggleAudioPressed:(id)sender {
    if (self.localMediaController.localAudioTrack) {
        [self.localMediaController destroyLocalAudioTrack];
    } else {
        [self.localMediaController createLocalAudioTrack];
    }

    self.audioToggleButton.selected = !self.localMediaController.localAudioTrack;
}

- (IBAction)toggleVideoPressed:(id)sender {
    if (self.localMediaController.localVideoTrack) {
        [self.localMediaController destroyLocalVideoTrack];
    } else {
        [self.localMediaController createLocalVideoTrack];
    }

    self.videoToggleButton.selected = !self.localMediaController.localVideoTrack;
    [self updateVideoUI:!self.localMediaController.localVideoTrack];
}

- (IBAction)settingsButtonPressed:(id)sender {
    NSString *currentTopology = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingsSelectedTopologyKey];
    NSString *newTopology = nil;

    if ([currentTopology isEqualToString:kTwilioVideoAppAPITopologyGroup]) {
        newTopology = kTwilioVideoAppAPITopologyP2P;
    } else {
        newTopology = kTwilioVideoAppAPITopologyGroup;
    }

    UIAlertAction *changeTopologyAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Use %@ Topology", newTopology]
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction *action) {
        [[NSUserDefaults standardUserDefaults] setValue:newTopology forKey:kSettingsSelectedTopologyKey];
    }];

    BOOL currentStatsState = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsEnableStatsCollectionKey];

    UIAlertAction *toggleStatsCollectionAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@ Stats Collection", currentStatsState ? @"Disable" : @"Enable"]
                                                                          style:UIAlertActionStyleDefault
                                                                        handler:^(UIAlertAction *action) {
        [[NSUserDefaults standardUserDefaults] setBool:!currentStatsState forKey:kSettingsEnableStatsCollectionKey];
    }];

    UIAlertAction *signOutAction = [UIAlertAction actionWithTitle:@"Sign Out" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [AuthStore.shared signOut];
    }];

    BOOL currentVp8Simulcast = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsEnableVp8SimulcastKey];

    UIAlertAction *toggleVp8SimulCast = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@ VP8 Simulcast", currentVp8Simulcast ? @"Disable" : @"Enable"]
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction *action) {
        [[NSUserDefaults standardUserDefaults] setBool:!currentVp8Simulcast forKey:kSettingsEnableVp8SimulcastKey];
    }];

    BOOL currentForceRelay = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsForceTurnRelay];

    UIAlertAction *toggleForceRelay = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@ TURN Relay", currentForceRelay ? @"Disable" : @"Enable"]
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action) {
                                                                   [[NSUserDefaults standardUserDefaults] setBool:!currentForceRelay forKey:kSettingsForceTurnRelay];
                                                               }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];


    NSDictionary* plistDict = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [NSString stringWithFormat:@"Twilio Video v%@ (%@)", [TwilioVideoSDK sdkVersion], plistDict[@"CFBundleVersion"]];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"VideoApp Settings"
                                                                             message:version
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:changeTopologyAction];
    [alertController addAction:toggleStatsCollectionAction];
    [alertController addAction:toggleVp8SimulCast];
    [alertController addAction:toggleForceRelay];

    [alertController addAction:signOutAction];
    [alertController addAction:cancelAction];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if ([sender isKindOfClass:[UIBarButtonItem class]]) {
            alertController.popoverPresentationController.barButtonItem = sender;
        } else if ([sender isKindOfClass:[UIView class]]) {
            alertController.popoverPresentationController.sourceView = sender;
            alertController.popoverPresentationController.sourceRect = ((UIView *)sender).bounds;
        }
    }

    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)flipCameraPressed:(id)sender {
    [self.localMediaController flipCamera];
}

- (IBAction)joinRoomButtonPressed:(id)sender {
    if ([self.roomTextField.text isEqualToString:@""]) {
        [self.roomTextField becomeFirstResponder];
    } else {
        [self dismissKeyboard];
        [self performSegueWithIdentifier:@"roomSegue" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"roomSegue"]) {
        self.roomViewController = segue.destinationViewController;
        self.roomViewController.roomName = self.roomTextField.text;
        self.roomViewController.localMediaController = self.localMediaController;
    }
}

-(BOOL)dismissKeyboard {
    BOOL dismissed = YES;

    if ([self.roomTextField isFirstResponder]) {
        [self.roomTextField resignFirstResponder];
    } else {
        dismissed = NO;
    }

    return dismissed;
}

- (void)handleDeepLinkedURL:(NSURL *)deepLinkedURL {
    // We only care about the user tapping the link if we are not currently in a room.
    if (!self.roomViewController) {
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:deepLinkedURL resolvingAgainstBaseURL:NO];

        if ([urlComponents.path hasPrefix:@"/room"]) {
            NSString *roomName = urlComponents.path.lastPathComponent;
            self.roomTextField.text = roomName;

            NSString *message = [NSString stringWithFormat:@"Would you like to join room: %@?", roomName];

            typeof(self) __weak weakSelf = self;

            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];

                UIAlertAction *join = [UIAlertAction actionWithTitle:@"Join" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    typeof(self) __strong strongSelf = weakSelf;
                    [strongSelf joinRoomButtonPressed:strongSelf];
                }];

                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Join Room?" message:message preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:cancel];
                [alert addAction:join];

                [self presentViewController:alert animated:YES completion:nil];
            }];
        }
    }
}

#pragma mark - LocalMediaControllerDelegate
- (void)localMediaControllerStartedVideoCapture:(LocalMediaController *)localMediaController {
    self.localVideoView.mirror = self.localMediaController.shouldMirrorLocalVideoView;

    self.localVideoView.hidden = NO;
    self.youLabel.hidden = YES;
    self.noVideoImage.hidden = YES;
}

@end
