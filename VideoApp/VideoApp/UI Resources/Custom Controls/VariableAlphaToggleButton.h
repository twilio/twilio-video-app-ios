//
//  VariableAlphaToggleButton.h
//  VideoApp
//
//  Created by Ryan Payne on 5/19/17.
//  Copyright © 2017 Twilio, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoundButton.h"

@interface VariableAlphaToggleButton : RoundButton

@property (nonatomic, assign) IBInspectable CGFloat stateNormalAlpha;
@property (nonatomic, assign) IBInspectable CGFloat stateSelectedAlpha;

@end
