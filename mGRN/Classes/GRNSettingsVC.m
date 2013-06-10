//
//  GRNSettingsVC.m
//  mGRN
//
//  Created by Anum on 13/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNSettingsVC.h"
#import <QuartzCore/QuartzCore.h>

@implementation GRNSettingsVC

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.okButton.layer.borderColor = self.cancelButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.okButton.layer.borderWidth = self.cancelButton.layer.borderWidth = 1.0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.masterHostLabel.text = [defaults objectForKey:KeySystemURI];
    self.domainLabel.text = [defaults objectForKey:KeyDomainName];
    self.version.text = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    [self setBgImage];
}

- (void)viewDidUnload {
    [self setBgImageView:nil];
    [self setVersion:nil];
    [self setMasterHostLabel:nil];
    [self setDomainLabel:nil];
    [self setPopUpTextField:nil];
    [self setPopUpView:nil];
    [self setOkButton:nil];
    [self setCancelButton:nil];
    [self setPopupHeading:nil];
    [super viewDidUnload];
}

-(BOOL)checkDetails
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (![[userDefault objectForKey:KeyDomainName] length] ||
        ![userDefault objectForKey:KeySystemURI])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter correct details to proceed"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }
    return YES;
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

- (IBAction)ok:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([self.popupHeading.text hasPrefix:@"Master"])
    {
        NSString *uri = [self.popUpTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
        [defaults setValue:uri forKey:KeySystemURI];
        self.masterHostLabel.text = self.popUpTextField.text;
    }
    else if ([self.popupHeading.text hasPrefix:@"Domain"])
    {
        [defaults setValue:self.popUpTextField.text forKey:KeyDomainName];
        self.domainLabel.text = self.popUpTextField.text;
    }
    self.popUpView.hidden = YES;
    [self.popUpTextField resignFirstResponder];
    [defaults synchronize];
}

- (IBAction)closePopup:(id)sender
{
    self.popUpView.hidden = YES;
    [self.popUpTextField resignFirstResponder];
}

- (IBAction)showDomainPopup:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.popupHeading.text = @"Domain";
    self.popUpTextField.text = [defaults objectForKey:KeyDomainName];
    self.popUpView.hidden = NO;
    [self.popUpTextField becomeFirstResponder];
}

- (IBAction)showMasterHostPopup:(id)sender
{
    self.popupHeading.text = @"Master Host";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.popUpTextField.text = [defaults objectForKey:KeySystemURI];
    self.popUpView.hidden = NO;
    [self.popUpTextField becomeFirstResponder];
}

- (IBAction)back:(id)sender
{
    self.popUpView.hidden = YES;
    if ([self checkDetails])
        [self dismissModalViewControllerAnimated:YES];
}
@end
