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

#import "LobbyViewController.h"
#import "TwilioVideoAppAPI.h"
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

    self.roomTextField.text = [SwiftToObjc roomNameFromDeepLink];
    
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
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(handleSettingChange) name:SwiftToObjc.appSettingsStoreDidChangeNotificationName object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self refresh];
}

- (void)handleSettingChange {
    // Restart local video so that resolution changes take place when video codec setting is changed.
    if (self.localMediaController.localVideoTrack) {
        [self.localMediaController destroyLocalVideoTrack];
        [self.localMediaController createLocalVideoTrack];
    }
    
    [self refresh];
}

- (void)refresh {
    self.loggedInUser.text = SwiftToObjc.userDisplayName;
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
    } else if ([segue.identifier isEqualToString:@"showSettings"]) {
        [SwiftToObjc prepareForShowSettingsSegue:segue];
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
