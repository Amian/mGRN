//
//  GRNCustomSegues.m
//  mGRN
//
//  Created by Anum on 28/04/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNCustomSegues.h"
#import "GRNTableContainerVCViewController.h"
#import "GRNOrderDetailsVC.h"

@implementation GRNCustomSegues

-(void)perform
{
    GRNOrderDetailsVC *source = self.sourceViewController;
    [self.sourceViewController addChildViewController:self.destinationViewController];

    CGRect frame = source.containerView.bounds;
    [self.destinationViewController view].frame = frame;
    [source.containerView addSubview:[self.destinationViewController view]];

    [self.destinationViewController didMoveToParentViewController:self.sourceViewController];
    ((GRNTableContainerVCViewController*)self.destinationViewController).delegate = self.sourceViewController;
}

@end
