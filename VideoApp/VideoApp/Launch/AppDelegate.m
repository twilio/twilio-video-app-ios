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

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "SettingsKeyConstants.h"
#import "TwilioVideoAppAPI.h"
#import "LobbyViewController.h"
#import "VideoApp-Swift.h"
@import TwilioVideo;

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
