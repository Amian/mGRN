//
//  GRNTableContainerVCViewController.h
//  mGRN
//
//  Created by Anum on 28/04/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Enums.h"
#import "GRNPurchaseOrderTableView.h"

@protocol TableContainerDelegate <NSObject>
-(void)tablecontainerDelegateChangedStatusTo:(TableNavigationStatus)newStatus;
@end

@interface GRNTableContainerVCViewController : UIViewController <UITableViewDelegate>
@property IBOutlet id<TableContainerDelegate> delegate;
@property (strong, nonatomic) IBOutlet GRNPurchaseOrderTableView *purchaseOrderTableView;
@property (strong, nonatomic) IBOutlet UIView *orderDetailView;
@property (strong, nonatomic) IBOutlet UIView *createGrnView;

@end
