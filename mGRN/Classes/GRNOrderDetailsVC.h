//
//  GRNOrderDetailsVC.h
//  mGRN
//
//  Created by Anum on 24/04/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRNTableContainerVCViewController.h"
#import "GRNContractTableView.h"
#import "GRNOrderItemsTableView.h"
#import "Enums.h"

@interface GRNOrderDetailsVC : UIViewController <TableContainerDelegate>

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIView *orderDetailView;
@property (strong, nonatomic) IBOutlet GRNContractTableView *contractsTableView;
@property (strong, nonatomic) IBOutlet GRNOrderItemsTableView *orderItemTableView;
@property (strong, nonatomic) IBOutlet GRNPurchaseOrderTableView *purchaseOrderTableView;
@property (strong, nonatomic) IBOutlet UIView *tablesView;
@property (strong, nonatomic) IBOutlet UIView *loadingView;

@property TableNavigationStatus status;

@property (strong, nonatomic) IBOutlet UIButton *navContract;
@property (strong, nonatomic) IBOutlet UIButton *navPurchaseOrders;
@property (strong, nonatomic) IBOutlet UIButton *navViewOrder;

@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UIToolbar *searchBar;

@property BOOL returnedAfterSubmission;
@end
