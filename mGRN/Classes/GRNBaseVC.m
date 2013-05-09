//
//  GRNBaseViewController.m
//  mGRN
//
//  Created by Anum on 24/04/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GRNBaseVC.h"
#import "GRNOrderDetailsVC.h"

#define TopBarTag 100

@interface GRNBaseVC ()
{
    bool viewHasLoaded;
}
@property (nonatomic, strong) GRNOrderDetailsVC *orderDetailsVC;
@end

@implementation GRNBaseVC
@synthesize orderDetailsVC;

-(void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated
{
    if (!viewHasLoaded)
    {
        [self addBorderToTopBar];
        viewHasLoaded = true;
    }
    [super viewDidAppear:animated];
}

#pragma mark - IB Actions

- (IBAction)logout:(id)sender {
}

- (IBAction)reload:(UIButton *)sender
{
    [self.orderDetailsVC reloadContracts];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"containerSegue"])
    {
        UINavigationController *nav = segue.destinationViewController;
        self.orderDetailsVC = [nav.viewControllers objectAtIndex:0];
    }
}

- (IBAction)search:(UIButton *)sender {
}

#pragma mark - View Adjustments

- (void)addBorderToTopBar
{
    // Add a bottomBorder
    UIView *topBar = (UIView*)[self.view viewWithTag:TopBarTag];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, topBar.frame.size.height - 1.0, topBar.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor whiteColor].CGColor;
    [topBar.layer addSublayer:bottomBorder];
}

@end
