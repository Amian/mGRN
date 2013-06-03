//
//  GRNSettingsVC.m
//  mGRN
//
//  Created by Anum on 13/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNSettingsVC.h"

@implementation GRNSettingsVC

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.systemURl.text = [defaults objectForKey:KeySystemURI];
    self.mgrnURL.text = [defaults objectForKey:KeyDomainName];
}

- (void)viewDidUnload {
    [self setSystemURl:nil];
    [self setMgrnURL:nil];
    [super viewDidUnload];
}
- (IBAction)save:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (self.systemURl.text.length)
    {
        NSString *uri = [self.systemURl.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    [defaults setValue:uri forKey:KeySystemURI];
    }
    if (self.mgrnURL.text.length)
    {
        [defaults setValue:self.mgrnURL.text forKey:KeyDomainName];
    }
    [defaults synchronize];
    if ([self checkDetails])
        [self dismissModalViewControllerAnimated:YES];
}
- (IBAction)cancel:(id)sender
{
    if ([self checkDetails])
    [self dismissModalViewControllerAnimated:YES];
}

-(BOOL)checkDetails
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (![[userDefault objectForKey:KeyDomainName] length] ||
        ![userDefault objectForKey:KeySystemURI])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter correct details to proceed"
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }
    return YES;
}
@end
