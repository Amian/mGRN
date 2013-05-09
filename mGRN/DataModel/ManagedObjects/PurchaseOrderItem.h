//
//  PurchaseOrderItem.h
//  mgrn
//
//  Created by Peter on 23/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GRNItem, PurchaseOrder;

@interface PurchaseOrderItem : NSManagedObject

@property (nonatomic, retain) NSDate * dueDate;
@property (nonatomic, retain) NSNumber * dueDateSpecified;
@property (nonatomic, retain) NSString * extraDescription;
@property (nonatomic, retain) NSString * itemDescription;
@property (nonatomic, retain) NSString * itemNumber;
@property (nonatomic, retain) NSNumber * plant;
@property (nonatomic, retain) NSNumber * quantityBalance;
@property (nonatomic, retain) NSString * uoq;
@property (nonatomic, retain) NSString * wbsCode;
@property (nonatomic, retain) NSSet *grnItems;
@property (nonatomic, retain) PurchaseOrder *purchaseOrder;
@end

@interface PurchaseOrderItem (CoreDataGeneratedAccessors)

- (void)addGrnItemsObject:(GRNItem *)value;
- (void)removeGrnItemsObject:(GRNItem *)value;
- (void)addGrnItems:(NSSet *)values;
- (void)removeGrnItems:(NSSet *)values;

@end
