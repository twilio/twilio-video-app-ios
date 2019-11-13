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
