//
//  AppDelegate.m
//  VideoApp
//
//  Created by Ryan Payne on 1/23/17.
//  Copyright © 2017 Twilio, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "SettingsKeyConstants.h"
#import "TwilioVideoAppAPI.h"
#import "LobbyViewController.h"
#import "VideoApp-Swift.h"
@import TwilioVideo;
@import HockeySDK;
@import Firebase;
@import GoogleSignIn;

#if APP_TYPE_TWILIO
const VideoAppEnvironment gCurrentAppEnvironment = VideoAppEnvironmentTwilio;
#elif APP_TYPE_INTERNAL
const VideoAppEnvironment gCurrentAppEnvironment = VideoAppEnvironmentInternal;
#elif APP_TYPE_COMMUNITY
const VideoAppEnvironment gCurrentAppEnvironment = VideoAppEnvironmentCommunity;
#endif

@interface AppDelegate () <GIDSignInDelegate>
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#ifndef DEBUG
    NSString *hockeyAppIdentifier = [[HockeyAppIdentifierFactory new] makeHockeyAppIdentifier];

    if (hockeyAppIdentifier != nil) {
        [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:hockeyAppIdentifier];
        [[BITHockeyManager sharedHockeyManager] startManager];
        [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
    }
#endif

    [[NSUserDefaults standardUserDefaults] registerDefaults:@{ kSettingsSelectedEnvironmentKey : kTwilioVideoAppAPIEnvironmentProduction,
                                                               kSettingsSelectedTopologyKey : kTwilioVideoAppAPITopologyGroup,
                                                               kSettingsEnableStatsCollectionKey : @(YES),
                                                               kSettingsEnableVp8SimulcastKey : @(NO),
                                                               kSettingsForceTurnRelay : @(NO)}];

    [TwilioVideoSDK setLogLevel:TVILogLevelInfo];

    NSLog(@"Twilio Video App Version: %@", [self applicationVersionString]);
    NSLog(@"Twilio Video SDK Version: %@", [TwilioVideoSDK sdkVersion]);

    switch (gCurrentAppEnvironment) {
        case VideoAppEnvironmentTwilio:
            NSLog(@"Twilio Video App Environment: Twilio");
            break;
        case VideoAppEnvironmentInternal:
            NSLog(@"Twilio Video App Environment: Internal");
            break;
        case VideoAppEnvironmentCommunity:
            NSLog(@"Twilio Video App Environment: Community");
            break;
        default:
            break;
    }

    // Use Firebase library to configure APIs
    [FIRApp configure];

    GIDSignIn *googleSignIn = [GIDSignIn sharedInstance];
    googleSignIn.clientID = [FIRApp defaultApp].options.clientID;
    googleSignIn.hostedDomain = @"twilio.com";
    googleSignIn.delegate = self;

    UINavigationController *navigationVC = (UINavigationController *)self.window.rootViewController;
    navigationVC.barHideOnSwipeGestureRecognizer.enabled = NO;
    navigationVC.hidesBarsOnSwipe = NO;

    return YES;
}

- (NSString *)applicationVersionString {
    NSDictionary* plistDict = [[NSBundle mainBundle] infoDictionary];
    return [NSString stringWithFormat:@"v%@ (%@)", plistDict[@"CFBundleShortVersionString"], plistDict[@"CFBundleVersion"]];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    if (navigationController.viewControllers.count != 1) {
        return;
    }

    // If we have a logged in user, display lobby screen
    if ([[FIRAuth auth] currentUser] != nil || [[GIDSignIn sharedInstance] hasAuthInKeychain] == YES) {
        [navigationController.topViewController performSegueWithIdentifier:@"lobbySegue" sender:self];
    } else {
        [navigationController.topViewController performSegueWithIdentifier:@"loginSegue" sender:self];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> *restorableObjects))restorationHandler {
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb] &&
        [self.window.rootViewController.presentedViewController isKindOfClass:[LobbyViewController class]]) {
        LobbyViewController *lobbyViewController = (LobbyViewController *)self.window.rootViewController.presentedViewController;
        [lobbyViewController handleDeepLinkedURL:userActivity.webpageURL];

        return YES;
    }

    return NO;
}

- (BOOL)application:(nonnull UIApplication *)application
            openURL:(nonnull NSURL *)url
            options:(nonnull NSDictionary<NSString *, id> *)options {
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                      annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

#pragma mark - GIDSignInDelegate methods
- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {

    if (error == nil) {
        GIDAuthentication *authentication = user.authentication;

        // Validate that the email address is indeed a twilio.com email address, else fail!
        if (![user.profile.email hasSuffix:@"@twilio.com"]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Unauthorized"
                                                                                     message:@"Only users with a Twilio email address are authorized to use this application."
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {}];
            [alertController addAction:okAction];
            [self.window.rootViewController.presentedViewController presentViewController:alertController animated:YES completion:nil];
            [[GIDSignIn sharedInstance] disconnect];

            return;
        }

        FIRAuthCredential *credential = [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                                                         accessToken:authentication.accessToken];
        [FirebaseAuthManager authenticateWithCredential:credential window:self.window];
    } else {
        switch (error.code){
            case kGIDSignInErrorCodeKeychain:
                // Indicates a problem reading or writing to the application keychain.
                NSLog(@"Google SignIn Error: Unable to access the keychain");
                break;
            case kGIDSignInErrorCodeNoSignInHandlersInstalled:
                // Indicates no appropriate applications are installed on the user's device which can handle
                // sign-in. This code will only ever be returned if using webview and switching to browser have
                // both been disabled.
                NSLog(@"Google SignIn Error: No sign in handlers installed");
                break;
            case kGIDSignInErrorCodeHasNoAuthInKeychain:
                // Indicates there are no auth tokens in the keychain. This error code will be returned by
                // signInSilently if the user has never signed in before with the given scopes, or if they have
                // since signed out.
                NSLog(@"Google SignIn Error: No auth tokens in Keychain");
                [signIn disconnect];
                break;
            case kGIDSignInErrorCodeCanceled:
                // Indicates the user canceled the sign in request.
                NSLog(@"Google SignIn Error: Sign in cancelled");
                break;
            case kGIDSignInErrorCodeUnknown:
            default:
                NSLog(@"An unknown error occurred.");
        }
    }
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {

    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    [navigationController popToRootViewControllerAnimated:YES];
    [navigationController.topViewController performSegueWithIdentifier:@"loginSegue" sender:self];
}

@end
