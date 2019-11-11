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

#if APP_TYPE_TWILIO
const VideoAppEnvironment gCurrentAppEnvironment = VideoAppEnvironmentTwilio;
#elif APP_TYPE_INTERNAL
const VideoAppEnvironment gCurrentAppEnvironment = VideoAppEnvironmentInternal;
#elif APP_TYPE_COMMUNITY
const VideoAppEnvironment gCurrentAppEnvironment = VideoAppEnvironmentCommunity;
#endif

@interface AppDelegate ()
@property (nonatomic, strong) id <LaunchFlow> launchFlow;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#ifndef DEBUG
    [[AppCenterStore new] start];
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
    }

    [AuthStore.shared start];

    if (@available(iOS 13, *)) {
        // Do nothing because SceneDelegate will handle it
    } else {
        self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        
        self.launchFlow = [[[LaunchFlowFactory alloc] init] makeLaunchFlowWithWindow: self.window];
        [self.launchFlow start];
    }

    return YES;
}

- (NSString *)applicationVersionString {
    NSDictionary* plistDict = [[NSBundle mainBundle] infoDictionary];
    return [NSString stringWithFormat:@"v%@ (%@)", plistDict[@"CFBundleShortVersionString"], plistDict[@"CFBundleVersion"]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    if (navigationController.viewControllers.count != 1) {
        return;
    }

    // If we have a logged in user, display lobby screen
    if (AuthStore.shared.isSignedIn) {
        [navigationController.topViewController performSegueWithIdentifier:@"lobbySegue" sender:self];
    } else {
        [navigationController.topViewController performSegueWithIdentifier:@"loginSegue" sender:self];
    }
}

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options API_AVAILABLE(ios(13)) {
    UISceneConfiguration* configuration = [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
    configuration.delegateClass = SceneDelegate.class;
    return configuration;
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
    return [AuthStore.shared openURL:url
                   sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                          annotation:options[UIApplicationOpenURLOptionsSourceApplicationKey]];
}

@end
