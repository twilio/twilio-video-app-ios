//
//  RoomViewController.h
//  VideoApp
//
//  Created by Ryan Payne on 5/17/17.
//  Copyright © 2017 Twilio, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LocalMediaController;

@interface RoomViewController : UIViewController

@property (nonatomic, strong, nonnull) LocalMediaController *localMediaController;
@property (nonatomic, copy, nonnull) NSString *identity;
@property (nonatomic, copy, nonnull) NSString *roomName;

@end
