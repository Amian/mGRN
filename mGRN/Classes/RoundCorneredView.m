//
//  RoundCorneredView.m
//  mGRN
//
//  Created by Anum on 06/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "RoundCorneredView.h"
#import <QuartzCore/QuartzCore.h>

@implementation RoundCorneredView

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.layer.cornerRadius = 35.0;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 2.0;
        self.clipsToBounds = YES;
    }
    return self;
}

@end
