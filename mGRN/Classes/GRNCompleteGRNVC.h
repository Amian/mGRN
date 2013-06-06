//
//  GRNCompleteGRNVC.h
//  mGRN
//
//  Created by Anum on 02/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRN+Management.h"
#import "DrawView.h"

#define KeyImage1 @"i1"
#define KeyImage2 @"i2"
#define KeyImage3 @"i3"
#define KeySignature @"s1"

@interface GRNCompleteGRNVC : UIViewController
@property (nonatomic, strong) GRN *grn;
@property (strong, nonatomic) IBOutlet UITextView *comments;

@property (strong, nonatomic) IBOutlet DrawView *signatureView;
@property (strong, nonatomic) IBOutlet UIView *photoView;
@property (strong, nonatomic) IBOutlet UILabel *photoLabel;
@property (strong, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (strong, nonatomic) IBOutlet UIButton *dateButton;

@property (nonatomic, strong) UIImage *signatureImage;

@property (nonatomic, strong) NSDictionary *grnDict;

//Containers
@property (strong, nonatomic) IBOutlet UIView *photoAndSignContainer;
@property (strong, nonatomic) IBOutlet UIView *dateAndNoteContainer;
@property (strong, nonatomic) IBOutlet UIButton *signButton;


@end
