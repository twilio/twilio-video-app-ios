//
//  TrackStatsTableViewCell.h
//  VideoApp
//
//  Created by Ryan Payne on 3/22/17.
//  Copyright © 2017 Twilio, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrackStatsTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *valueLabel;

@end
