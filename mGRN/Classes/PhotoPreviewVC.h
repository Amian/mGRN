//
//  PhotoPreviewVC.h
//  mGRN
//
//  Created by Anum on 08/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoPreviewVC : UIViewController
@property (nonatomic, strong) UIImage *image;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@end
