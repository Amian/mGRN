//
//  GRNPurchaseOrderTableView.h
//  mGRN
//
//  Created by Anum on 24/04/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contract.h"
#import "GRNBaseTable.h"

@interface GRNPurchaseOrderTableView : GRNBaseTable
@property (nonatomic, strong) Contract *contract;
@end
