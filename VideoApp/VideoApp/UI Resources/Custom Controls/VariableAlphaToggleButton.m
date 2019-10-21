//
//  VariableAlphaToggleButton.m
//  VideoApp
//
//  Created by Ryan Payne on 5/19/17.
//  Copyright © 2017 Twilio, Inc. All rights reserved.
//

#import "VariableAlphaToggleButton.h"

@implementation VariableAlphaToggleButton

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    CGFloat newAlpha;

    if (selected) {
        newAlpha = self.stateSelectedAlpha;
    } else {
        newAlpha = self.stateNormalAlpha;
    }

    self.layer.backgroundColor = CGColorCreateCopyWithAlpha(self.layer.backgroundColor, newAlpha);
}

@end
