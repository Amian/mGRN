//
//  PopVCSegue.m
//  mGRN
//
//  Created by Anum on 29/04/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "PopVCSegue.h"

@implementation PopVCSegue

-(void)perform
{
    UIViewController *vc = self.sourceViewController;
    if ([self.identifier isEqualToString:@"SubmitGRN"])
    {
        [vc.navigationController pushViewController:self.destinationViewController animated:YES];
        vc.navigationController.viewControllers = [NSArray arrayWithObject:self.destinationViewController];
    }
    else
    {
        [vc.navigationController popViewControllerAnimated:YES];
    }
}
@end
