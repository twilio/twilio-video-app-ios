//
//  StatsViewController.h
//  VideoApp
//
//  Created by Ryan Payne on 3/16/17.
//  Copyright © 2017 Twilio, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StatsUIModel;

@interface StatsViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

- (void)addAsSwipeableViewToParentViewController:(UIViewController *)parentViewController;

- (void)updateStatsUIWithModels:(NSArray<StatsUIModel *> *)statsUIModels;

@end
