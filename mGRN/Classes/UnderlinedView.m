//
//  UnderlinedView.m
//  mGRN
//
//  Created by Anum on 09/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "UnderlinedView.h"
#import <QuartzCore/QuartzCore.h>
@implementation UnderlinedView

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        // Add a bottomBorder
        UIView *bottomBorder = [[UIView alloc] init];
        bottomBorder.frame = CGRectMake(0.0f, self.frame.size.height - 1.0, self.frame.size.width, 1.0f);
        bottomBorder.backgroundColor = [UIColor whiteColor];
        bottomBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:bottomBorder];
    }
    return self;
}

@end
