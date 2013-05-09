//
//  PhotoPreviewVC.m
//  mGRN
//
//  Created by Anum on 08/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "PhotoPreviewVC.h"

@implementation PhotoPreviewVC

- (IBAction)close:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.image.imageOrientation == UIImageOrientationUp || self.image.imageOrientation == UIImageOrientationDown)
    {
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    else
    {
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    self.imageView.image = self.image;
}
@end
