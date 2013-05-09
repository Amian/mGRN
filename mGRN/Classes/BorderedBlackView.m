//
//  BorderedBlackView.m
//  mGRN
//
//  Created by Anum on 29/04/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "BorderedBlackView.h"
#import <QuartzCore/QuartzCore.h>

@implementation BorderedBlackView

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    return self;
}

@end
