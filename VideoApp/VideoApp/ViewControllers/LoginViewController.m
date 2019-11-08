//
//  LoginViewController.m
//  VideoApp
//
//  Created by Ryan Payne on 1/24/17.
//  Copyright © 2017 Twilio, Inc. All rights reserved.
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
