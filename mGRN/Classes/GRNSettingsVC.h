//
//  GRNSettingsVC.h
//  mGRN
//
//  Created by Anum on 13/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GRNSettingsVC : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *bgImageView;
@property (strong, nonatomic) IBOutlet UILabel *version;

@property (strong, nonatomic) IBOutlet UILabel *masterHostLabel;
@property (strong, nonatomic) IBOutlet UILabel *domainLabel;

@property (strong, nonatomic) IBOutlet UITextField *popUpTextField;
@property (strong, nonatomic) IBOutlet UIButton *popUpView;

@property (strong, nonatomic) IBOutlet UILabel *popupHeading;
@property (strong, nonatomic) IBOutlet UIButton *okButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;

- (IBAction)closePopup:(id)sender;

@end
