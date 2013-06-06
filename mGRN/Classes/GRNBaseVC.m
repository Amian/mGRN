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
@end

@implementation GRNBaseVC

-(void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];
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

-(void)viewWillUnload
{
    [super viewWillUnload];
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
    NSLog(@"content = %@, frame = %@",NSStringFromCGSize(self.scrollView.contentSize),NSStringFromCGRect(self.scrollView.frame));

    [self setScrollViewSize];

}

-(void)onKeyboardShow:(NSNotification *)notification
{
//    CGRect keyboardFrame = [[[notification userInfo] valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue]; //height of keyboard
    
    keyboardVisible = YES;
    [self setScrollViewSize];
    
    NSLog(@"content = %@, frame = %@",NSStringFromCGSize(self.scrollView.contentSize),NSStringFromCGRect(self.scrollView.frame));
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
        self.scrollView.contentSize = CGSizeZero;
    }
}

@end
