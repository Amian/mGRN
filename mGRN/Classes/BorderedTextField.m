//
//  BorderedTextField.m
//  mGRN
//
//  Created by Anum on 12/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "BorderedTextField.h"
#import <QuartzCore/QuartzCore.h>

@interface BorderedTextField()
@property (nonatomic, assign) float verticalPadding;
@property (nonatomic, assign) float horizontalPadding;
@end

@implementation BorderedTextField
@synthesize horizontalPadding, verticalPadding;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.backgroundColor = [UIColor blackColor];
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.horizontalPadding = 15.0;
        self.font = [UIFont systemFontOfSize:20.0];
        self.textColor = [UIColor whiteColor];
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + horizontalPadding, bounds.origin.y + verticalPadding, bounds.size.width - horizontalPadding*2, bounds.size.height - verticalPadding*2);
}
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

-(BOOL)becomeFirstResponder
{
    BOOL x = [super becomeFirstResponder];
    if (x)
        self.layer.borderColor = GRNLightBlueColour.CGColor;
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
