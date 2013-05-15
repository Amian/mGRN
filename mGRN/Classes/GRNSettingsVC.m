//
//  GRNSettingsVC.m
//  mGRN
//
//  Created by Anum on 13/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNSettingsVC.h"

@implementation GRNSettingsVC

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
    [defaults setValue:self.systemURl.text forKey:KeySystemURI];
    }
    if (self.mgrnURL.text.length)
    {
        [defaults setValue:self.mgrnURL.text forKey:KeymGRNURI];
    }
    [defaults synchronize];
    [self dismissModalViewControllerAnimated:YES];
}
- (IBAction)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}
@end
