//
//  BorderedTextView.m
//  mGRN
//
//  Created by Anum on 05/06/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "BorderedTextView.h"
#import <QuartzCore/QuartzCore.h>

@implementation BorderedTextView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.font = [UIFont systemFontOfSize:20.0];
        self.textColor = [UIColor whiteColor];
    }
    return self;
}

-(BOOL)becomeFirstResponder
{
    BOOL x = [super becomeFirstResponder];
    if (x)
        self.layer.borderColor = [UIColor orangeColor].CGColor;
    return x;
}

-(BOOL)resignFirstResponder
{
    BOOL x = [super resignFirstResponder];
    if (x)
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    return x;
}

@end
