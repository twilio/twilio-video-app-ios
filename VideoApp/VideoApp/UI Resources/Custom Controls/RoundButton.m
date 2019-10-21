//
//  RoundButton.m
//  VideoApp
//
//  Created by Ryan Payne on 5/17/17.
//  Copyright © 2017 Twilio, Inc. All rights reserved.
//

#import "RoundButton.h"

@implementation RoundButton

- (void)awakeFromNib {
    [super awakeFromNib];

    self.layer.cornerRadius = self.bounds.size.width / 2.0;
}

@end
