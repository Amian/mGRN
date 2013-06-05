//
//  GRNBaseViewController.m
//  mGRN
//
//  Created by Anum on 24/04/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GRNBaseVC.h"

@interface GRNBaseVC ()
@end

@implementation GRNBaseVC

-(void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setBgImage];
}

- (void)viewDidUnload {
    [self setBgImageView:nil];
    [super viewDidUnload];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setBgImage];
}

-(void)setBgImage
{
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
    {
        self.bgImageView.image = [UIImage imageNamed:@"home_bg_landscape_mgrn_1.png"];
    }
    else
    {
        self.bgImageView.image = [UIImage imageNamed:@"bg_mgrn.jpg"];
    }
}
@end
