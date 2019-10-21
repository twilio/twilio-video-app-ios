//
//  TrackStatsTableViewCell.m
//  VideoApp
//
//  Created by Ryan Payne on 3/22/17.
//  Copyright © 2017 Twilio, Inc. All rights reserved.
//

#import "TrackStatsTableViewCell.h"

@implementation TrackStatsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];

    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    NSLayoutConstraint *titleCenterConstraint = [NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                             attribute:NSLayoutAttributeCenterY
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.contentView
                                                                             attribute:NSLayoutAttributeCenterY
                                                                            multiplier:1.0
                                                                              constant:0];

    NSLayoutConstraint *titleLeftAnchorConstraint = [self.titleLabel.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor constant:self.contentView.layoutMargins.left];

    NSLayoutConstraint *titleWidthConstraint = [NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                             attribute:NSLayoutAttributeWidth
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.contentView
                                                                             attribute:NSLayoutAttributeWidth
                                                                            multiplier:.5
                                                                              constant:0];

    self.valueLabel.translatesAutoresizingMaskIntoConstraints = NO;

    NSLayoutConstraint *valueCenterConstraint = [NSLayoutConstraint constraintWithItem:self.valueLabel
                                                                             attribute:NSLayoutAttributeCenterY
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.contentView
                                                                             attribute:NSLayoutAttributeCenterY
                                                                            multiplier:1.0
                                                                              constant:0];

    NSLayoutConstraint *valueRightAnchorConstraint = [self.valueLabel.rightAnchor constraintEqualToAnchor:self.contentView.rightAnchor constant:self.contentView.layoutMargins.right];

    NSLayoutConstraint *valueWidthConstraint = [NSLayoutConstraint constraintWithItem:self.valueLabel
                                                                            attribute:NSLayoutAttributeWidth
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.contentView
                                                                            attribute:NSLayoutAttributeWidth
                                                                           multiplier:.5
                                                                             constant:0];

    [NSLayoutConstraint activateConstraints:@[ titleCenterConstraint,
                                               titleLeftAnchorConstraint,
                                               titleWidthConstraint,
                                               valueCenterConstraint,
                                               valueRightAnchorConstraint,
                                               valueWidthConstraint ] ];
}

@end
