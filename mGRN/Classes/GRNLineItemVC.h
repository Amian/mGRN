//
//  GRNLineItemVC.h
//  mGRN
//
//  Created by Anum on 02/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRN.h"
#import "GRNOrderItemsTableView.h"
#import "GRNWbsTableView.h"

@interface GRNLineItemVC : UIViewController <UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) GRN *grn;
@property (strong, nonatomic) IBOutlet GRNOrderItemsTableView *itemTableView;
@property (strong, nonatomic) IBOutlet UILabel *itemLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UITextField *quantityDelivered;
@property (strong, nonatomic) IBOutlet UITextField *quantityRejected;
@property (strong, nonatomic) IBOutlet UITextField *note;
@property (strong, nonatomic) IBOutlet UILabel *expected;
@property (strong, nonatomic) IBOutlet UIButton *wbsButton;
@property (strong, nonatomic) IBOutlet UITextField *sdnTextField;
@property (strong, nonatomic) IBOutlet UIView *resonView;
@property (strong, nonatomic) IBOutlet UIView *wbsView;
- (IBAction)back:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *reasonButton;
@property (strong, nonatomic) IBOutlet GRNWbsTableView *wbsTable;

@property (nonatomic,strong) NSDictionary *grnDict;

@property (strong, nonatomic) IBOutlet UIToolbar *searchBar;
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;

@property (strong, nonatomic) IBOutlet UILabel *serialNumberLabel;
@property (strong, nonatomic) IBOutlet UITextField *serialNumber;
@property (strong, nonatomic) IBOutlet UILabel *wbsCodeLabel;
@property (strong, nonatomic) IBOutlet UIView *viewBelowWbsCode;

@end
