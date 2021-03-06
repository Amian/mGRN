//
//  GRNLoginVC.m
//  mGRN
//
//  Created by Anum on 01/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//
#import "GRNLoginVC.h"
#import "GRNBaseVC.h"
#import "GRNAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "LoadingView.h"
#import "M1X.h"
#import "M1XRequestHeader.h"
#import "GRNM1XHeader.h"
#import "SDN+Management.h"
#import "CoreDataManager.h"

#define LoginBoxTag 101

@interface GRNLoginVC() <M1XDelegate, UITextFieldDelegate>
{
    BOOL animationInProgress;
    CGPoint originalCenter;
    BOOL keyboardVisible;
}
@property (nonatomic, strong) UIView *loadingView;
@end

@implementation GRNLoginVC

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (!animationInProgress)
    {
        UIView *loginBox = [self.view viewWithTag:LoginBoxTag];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        self.mgrnLogo.center = CGPointMake(loginBox.center.x, loginBox.frame.origin.y - self.mgrnLogo.frame.size.height - 10.0);
        [UIView commitAnimations];
    }
    [self adjustViewForKeyboard];
    [self setBgImage];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    
    self.username.text = AmIBeingDebugged()? @"chaamu" : @"";
    self.password.text = AmIBeingDebugged()? @"cham" : @"";
    
    [self setBgImage];
    self.hiddenView.alpha = 0.0;
    self.mgrnLogo.alpha = 1.0;
    self.mgrnLogo.center = self.hiddenView.center;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (![[userDefault objectForKey:KeyDomainName] length] ||
        ![userDefault objectForKey:KeySystemURI])
    {
        [self performSegueWithIdentifier:@"settings" sender:self];
        return;
    }
    [self animationPartOne];
}

- (void)viewDidUnload {
    [self setHiddenView:nil];
    [self setUsername:nil];
    [self setPassword:nil];
    [self setMgrnLogo:nil];
    [self setBgImageView:nil];
    [super viewDidUnload];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return !animationInProgress;
}

#pragma mark - Login

-(IBAction)login
{
    if (!self.username.text.length || !self.password.text.length)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter username and password."
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
            [self earthquake:self.hiddenView];
        return;
    }
    self.loadingView = [LoadingView loadingViewWithFrame:self.view.bounds];
    [self.view addSubview:self.loadingView];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self createNewSession];
    }];
}

-(void)createNewSession
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    M1XRequestHeader *header = [[M1XRequestHeader alloc] init];
    header.userId = self.username.text;
    header.password = self.password.text;
    header.domain = [userDefault objectForKey:KeyDomainName];
    header.role = GRNRole;
    header.transactionId = [[NSProcessInfo processInfo] globallyUniqueString];
    
    //Save session values
    [userDefault setValue:header.transactionId forKey:KeyTransactionID];
    [userDefault setValue:header.role forKey:KeyRole];
    [userDefault synchronize];
    
    M1X *m1x = [[M1X alloc] init];
    m1x.delegate = self;
    [m1x newSessionForAppName:GRNAppName withHeader:header];
}

#pragma mark - Animation

-(void)animationPartOne
{
    animationInProgress = YES;
    [self performSelector:@selector(animationPartTwo) withObject:nil afterDelay:0.7];
}

-(void)animationPartTwo
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    self.mgrnLogo.alpha = 0.0;
    [UIView commitAnimations];
    [self performSelector:@selector(animationPartThree) withObject:nil afterDelay:0.3];
}

-(void)animationPartThree
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    self.hiddenView.alpha = 1.0;
    [UIView commitAnimations];
    [self performSelector:@selector(animationPartFour) withObject:nil afterDelay:1.0];
}

-(void)animationPartFour
{
    UIView *loginBox = [self.view viewWithTag:LoginBoxTag];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:2.0];
    self.mgrnLogo.alpha = 1.0;
    self.mgrnLogo.center = CGPointMake(loginBox.center.x, loginBox.frame.origin.y - self.mgrnLogo.frame.size.height - 10.0);
    [UIView commitAnimations];
    [self performSelector:@selector(animationComplete) withObject:nil afterDelay:2.0];
}

-(void)animationComplete
{
    animationInProgress = NO;
}

#pragma mark - Earthquake

- (void)earthquake:(UIView*)itemView
{
    CGFloat t = 2.0;
    
    CGAffineTransform leftQuake  = CGAffineTransformTranslate(CGAffineTransformIdentity, t, -t);
    CGAffineTransform rightQuake = CGAffineTransformTranslate(CGAffineTransformIdentity, -t, t);
    
    itemView.transform = leftQuake;  // starting point
    
    [UIView beginAnimations:@"earthquake" context:(__bridge void *)(itemView)];
    [UIView setAnimationRepeatAutoreverses:YES]; // important
    [UIView setAnimationRepeatCount:5];
    [UIView setAnimationDuration:0.07];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(earthquakeEnded:finished:context:)];
    
    itemView.transform = rightQuake; // end here & auto-reverse
    
    [UIView commitAnimations];
}

- (void)earthquakeEnded:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([finished boolValue])
    {
        UIView* item = (__bridge UIView *)context;
        item.transform = CGAffineTransformIdentity;
    }
}

#pragma mark - M1X Delegate

-(void)onNewSessionSuccess:(M1XSession *)session
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:session.userId forKey:KeyUserID];
    [userDefault setValue:session.sessionEndDT forKey:KeySessionEndDate];
    [userDefault setValue:session.sessionKey forKey:KeyPassword];
    [userDefault setValue:session.kco forKey:KeyKCO];
    [userDefault synchronize];
    
    M1XRequestHeader *header = [GRNM1XHeader Header];
    M1X *m1x = [[M1X alloc] init];
    m1x.delegate = self;
    [m1x FetchServiceConnectionDetailsForAppName:GRNAppName withHeader:header];
    
}

-(void)onServiceConnectionSuccess:(M1XServiceConnection *)service
{
    if (!service.port.length || !service.server.length || !service.serviceName.length)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Exception"
                                                        message:@"Could not retrieve service connection details."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:service.port forKey:KeyServicePort];
    [userDefault setValue:service.server forKey:KeyServiceServer];
    [userDefault setValue:service.serviceName forKey:KeyServiceName];
    [userDefault synchronize];
    
    [self initialSetup];
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
    [self performSegueWithIdentifier:@"login" sender:nil];
    [self.loadingView removeFromSuperview];
}

-(void)onNewSessionFailure:(M1XResponse *)response exceptionType:(M1xException)exception
{
    [self.loadingView removeFromSuperview];
    [self earthquake:self.hiddenView];
    if (exception != 0)
    {
        NSString *message = @"";
        switch (exception)
        {
            case M1xExceptionAuthenticationFailed:
            {
                message = @"Authentication has failed. Please try a different ￼username/password.";
                break;
            }
            case M1xExceptionNoSuccess:
            {
                message = @"Unable to connect to server.";
                break;
            }
            case M1xExceptionNoInternetConnection:
                break;
            case M1xExceptionNone:
            default:
                message = @"Unknown exception.";
                break;
        }
        if (message.length)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Exception"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

-(void)initialSetup
{
    [SDN removeExpiredSDNinMOC:[CoreDataManager moc]];
    [CoreDataManager removeData:NO];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:nil forKey:KeyImage1];
    [defaults setValue:nil forKey:KeyImage2];
    [defaults setValue:nil forKey:KeyImage3];
    [defaults setValue:nil forKey:KeySignature];
    [defaults synchronize];
    [[CoreDataManager sharedInstance] submitAnyGrnsAwaitingSubmittion];
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



-(void)onKeyboardHide:(NSNotification *)notification
{
    keyboardVisible = NO;
    [self adjustViewForKeyboard];
}

-(void)onKeyboardShow:(NSNotification *)notification
{
    keyboardVisible = YES;
    [self adjustViewForKeyboard];
}

-(void)adjustViewForKeyboard
{
    if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) && keyboardVisible)
    {
        CGRect rect = self.view.bounds;
        rect.origin.y = 100.0;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        self.view.bounds = rect;
        [UIView commitAnimations];
    }
    else
    {
        CGRect rect = self.view.bounds;
        rect.origin = CGPointZero;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        self.view.bounds = rect;
        [UIView commitAnimations];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.username])
    {
        [self.password becomeFirstResponder];
    }
    else if ([textField isEqual:self.password])
    {
        if (self.username.text.length || self.password.text.length)
        {
            [self login];
        }
    }
    return YES;
}
@end