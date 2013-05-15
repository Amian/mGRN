//
//  GRNOrderItemsTableView.h
//  mGRN
//
//  Created by Anum on 25/04/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRNBaseTable.h"
#import "GRNItem.h"
#import "PurchaseOrder.h"
@interface GRNOrderItemsTableView : GRNBaseTable <UITableViewDelegate>
@property (nonatomic, strong) PurchaseOrder *purchaseOrder;
@property (nonatomic, strong) NSArray *grnItems;
@end
