//
//  GRNLoginVC.h
//  mGRN
//
//  Created by Anum on 01/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GRNLoginVC : UIViewController
@property (strong, nonatomic) IBOutlet UIView *loginContainer;
@property (strong, nonatomic) IBOutlet UIImageView *companyLogo;

@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UILabel *errorLabel;

@property (strong, nonatomic) IBOutlet UIView *coinsLogoView;
@property (strong, nonatomic) IBOutlet UILabel *poweredByPervasicLabel;
@property (strong, nonatomic) IBOutlet UILabel *appTitleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *mgrnLogo;
@end
