//
//  GRNItem.h
//  mgrn
//
//  Created by Peter on 23/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GRN, PurchaseOrderItem;

@interface GRNItem : NSManagedObject

@property (nonatomic, retain) NSString * exception;
@property (nonatomic, retain) NSString * itemNumber;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * quantityDelivered;
@property (nonatomic, retain) NSNumber * quantityRejected;
@property (nonatomic, retain) NSString * serialNumber;
@property (nonatomic, retain) NSString * uoq;
@property (nonatomic, retain) NSString * wbsCode;
@property (nonatomic, retain) GRN *grn;
@property (nonatomic, retain) PurchaseOrderItem *purchaseOrderItem;

@end
