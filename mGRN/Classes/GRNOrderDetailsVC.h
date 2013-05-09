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

@interface GRNOrderDetailsVC : UIViewController <TableContainerDelegate>

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIView *orderDetailView;
@property (strong, nonatomic) IBOutlet GRNContractTableView *contractsTableView;
@property (strong, nonatomic) IBOutlet GRNOrderItemsTableView *orderItemTableView;
@property (strong, nonatomic) IBOutlet GRNPurchaseOrderTableView *purchaseOrderTableView;
@property (strong, nonatomic) IBOutlet UIView *tablesView;
-(void)reloadContracts;
@property (strong, nonatomic) IBOutlet UIView *loadingView;


@property (strong, nonatomic) IBOutlet UIButton *navContract;
@property (strong, nonatomic) IBOutlet UIButton *navPurchaseOrders;
@property (strong, nonatomic) IBOutlet UIButton *navViewOrder;
@end
