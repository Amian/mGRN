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

@interface GRNLoginVC() <M1XDelegate>
{
    BOOL animationInProgress;
    CGPoint originalCenter;
}
@property (nonatomic, strong) UIView *loadingView;
@end

@implementation GRNLoginVC

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.appTitleLabel.text = [NSString stringWithFormat:@"Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    originalCenter = self.loginContainer.center;
    self.errorLabel.hidden = YES;
    [self animationPartOne];
}

- (void)viewDidUnload {
    [self setLoginContainer:nil];
    [self setCompanyLogo:nil];
    [self setUsername:nil];
    [self setPassword:nil];
    [self setCoinsLogoView:nil];
    [self setPoweredByPervasicLabel:nil];
    [self setErrorLabel:nil];
    [self setAppTitleLabel:nil];
    [self setMgrnLogo:nil];
    [super viewDidUnload];
}


#pragma mark - Login

-(IBAction)login
{
    self.loadingView = [LoadingView loadingViewWithFrame:self.view.bounds];
    [self.view addSubview:self.loadingView];
    [self createNewSession];
}

-(void)createNewSession
{
    M1XRequestHeader *header = [[M1XRequestHeader alloc] init];
    header.userId = self.username.text;
    header.password = self.password.text;
    header.domain = GRNDomainName;
    header.role = GRNRole;
    header.transactionId = @"123";
    
    //TODO: Create a unique GUID
    //    header.transactionId = (NSString*)[[UIDevice currentDevice] identifierForVendor];
    
    //Save session values
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:header.domain forKey:KeyDomainName];
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
    self.coinsLogoView.alpha = 0.0;
    self.loginContainer.alpha = 0.0;
    self.mgrnLogo.alpha = 1.0;
    
    originalCenter = self.mgrnLogo.center;
    self.mgrnLogo.center = self.loginContainer.center;
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
    self.loginContainer.alpha = 1.0;
    self.coinsLogoView.alpha = 1.0;
    [UIView commitAnimations];
    [self performSelector:@selector(animationPartFour) withObject:nil afterDelay:1.0];
}

-(void)animationPartFour
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    self.mgrnLogo.alpha = 1.0;
    self.mgrnLogo.center = originalCenter;
    [UIView commitAnimations];
}
//
//
//-(void)runAnimation
//{
//    self.loginContainer.alpha = 0.0;
//    self.poweredByPervasicLabel.alpha = 0.0;
//    [self.username resignFirstResponder];
//    [self.password resignFirstResponder];
//    self.coinsLogoView.clipsToBounds = NO;
//    self.coinsLogoView.center = CGPointMake(self.view.bounds.size.width/2,
//                                               self.view.bounds.size.height/2);
//    
//    [self performSelector:@selector(animationStageOne) withObject:nil afterDelay:0.2];
//}
//
//-(void)animationStageOne
//
//{
//    self.coinsLogoView.center = CGPointMake(self.view.bounds.size.width/2,
//                                               self.view.bounds.size.height/2);
//    CABasicAnimation* rotationAnimation;
//    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * 1];
//    rotationAnimation.duration = 1.0;
//    rotationAnimation.timingFunction =
//    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    [self.coinsLogoView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
//    [self performSelector:@selector(animationStageTwo) withObject:nil afterDelay:1.0];
//}
//
//- (void)animationStageTwo
//{
//    animationInProgress = YES;
//    CGRect pervasicFrame = self.poweredByPervasicLabel.frame;
//    pervasicFrame.origin.y += 20.0;
//    self.poweredByPervasicLabel.frame = pervasicFrame;
//    
//    pervasicFrame.origin.y -= 20.0;
//    
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:1.0];
//    self.poweredByPervasicLabel.frame = pervasicFrame;
//    self.poweredByPervasicLabel.alpha = 1.0;
//    [UIView commitAnimations];
//    [self performSelector:@selector(animationStageThree) withObject:nil afterDelay:1.0];
//}
//
//-(void)animationStageThree
//{
//    CGRect logoFrame = self.coinsLogoView.frame;
//    logoFrame.origin.y = self.view.bounds.size.height - self.coinsLogoView.bounds.size.height - 30.0;
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:1.0];
//    self.coinsLogoView.frame = logoFrame;
//    [UIView commitAnimations];
//    [self performSelector:@selector(animationStageFour) withObject:nil afterDelay:1.0];
//}
//
//-(void)animationStageFour
//{
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:1.0];
//    self.loginContainer.alpha = 1.0;
//    self.companyLogo.alpha = 1.0;
//    [UIView commitAnimations];
//    animationInProgress = NO;
//    [self.username performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:1.0];
//    
//}
//
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
    [self.loadingView removeFromSuperview];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:session.userId forKey:KeyUserID];
    [userDefault setValue:session.sessionEndDT forKey:KeySessionEndDate];
    [userDefault setValue:session.sessionKey forKey:KeyPassword];
    [userDefault setValue:session.kco forKey:KeyKCO];
    [userDefault synchronize];
    [self performSegueWithIdentifier:@"login" sender:nil];
}

-(void)onNewSessionFailure:(M1XResponse *)response
{
    [self.loadingView removeFromSuperview];
    [self earthquake:self.loginContainer];
    self.errorLabel.hidden = NO;
}
@end
