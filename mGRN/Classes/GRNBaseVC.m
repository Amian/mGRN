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
{
    BOOL keyboardVisible;
}
@property (nonatomic, strong) UIAlertView *warningAlert;

@end

@implementation GRNBaseVC
@synthesize warningAlert;

-(void)viewDidLoad
{
    //Notify if scroll view offset needs to be changed
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeScrollViewOffset:) name:ChangeScrollViewContentOffsetNotification object:nil];
    
    
    //Notify when keyboard appears
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    NSDate *expiryDate = [formatter dateFromString:[defaults objectForKey:KeySessionEndDate]];
    NSTimeInterval i = [expiryDate timeIntervalSinceDate:[NSDate date]];
    NSTimeInterval warning = [expiryDate timeIntervalSinceDate:[NSDate date]] - (10.0*60.0);

    [self performSelector:@selector(sessionWarining)
               withObject:nil
     afterDelay:warning];

    [self performSelector:@selector(sessionExpired)
               withObject:nil
               afterDelay:i];

    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.scrollView.contentOffset = CGPointZero;

    [super viewWillAppear:animated];
    [self setBgImage];
    [self setScrollViewSize];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ChangeScrollViewContentOffsetNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidUnload {
    [self setBgImageView:nil];
    [self setScrollView:nil];
    [self setContainer:nil];
    [super viewDidUnload];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setBgImage];
    [self setScrollViewSize];
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

#pragma mark - Keyboard Notifications

-(void)onKeyboardHide:(NSNotification *)notification
{
    keyboardVisible = NO;
    [self setScrollViewSize];
}

-(void)onKeyboardShow:(NSNotification *)notification
{
//    CGRect keyboardFrame = [[[notification userInfo] valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue]; //height of keyboard
    
    keyboardVisible = YES;
    [self setScrollViewSize];
}

-(void)setScrollViewSize
{
    if (keyboardVisible)
    {
    CGFloat KeyboardHeight = UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])? 352.0 : 264.0;
    CGRect frame = self.scrollView.frame;
    frame.size.height = self.view.bounds.size.height-KeyboardHeight;
    self.scrollView.frame = frame;
    self.scrollView.contentSize = self.view.bounds.size;
    self.container.frame = self.view.bounds;
    }
    else
    {
        self.scrollView.frame = self.view.bounds;
        self.container.frame = self.view.bounds;
        self.scrollView.contentSize = self.view.bounds.size;
    }
}

-(void)sessionWarining
{
    self.warningAlert = [[UIAlertView alloc] initWithTitle:@"You session is about to expire. You will be automatically logged out in 10 minutes."
                                                    message:nil
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [self.warningAlert show];
}

-(void)sessionExpired
{
    [self dismissModalViewControllerAnimated:NO];
    [self.warningAlert removeFromSuperview];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Session Expired"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
}

-(void)changeScrollViewOffset:(NSNotification*)info
{
    CGFloat KeyboardHeight = UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])? 352.0 : 264.0;

    if (self.scrollView.contentOffset.y == 0.0)
    [self.scrollView setContentOffset:CGPointMake(0.0, KeyboardHeight) animated:YES];
}
@end
