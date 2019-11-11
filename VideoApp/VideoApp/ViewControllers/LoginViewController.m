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

#import "LoginViewController.h"
@import GoogleSignIn;

@interface LoginViewController() <GIDSignInUIDelegate>
@property (weak, nonatomic) IBOutlet GIDSignInButton *googleSignInButton;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [GIDSignIn sharedInstance].uiDelegate = self;
    self.googleSignInButton.style = kGIDSignInButtonStyleWide;
}

- (BOOL)isModalInPresentation {
    // Swiping to dismiss the LoginViewController is not desirable, even when it is presented modally on an iPad.
    return YES;
}

@end
