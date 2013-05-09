//
//  PurchaseOrder.h
//  mgrn
//
//  Created by Peter on 23/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contract, GRN, PurchaseOrderItem;

@interface PurchaseOrder : NSManagedObject

@property (nonatomic, retain) NSString * attention;
@property (nonatomic, retain) NSString * attentionPhone;
@property (nonatomic, retain) NSNumber * mpo;
@property (nonatomic, retain) NSString * orderDescription;
@property (nonatomic, retain) NSString * orderName;
@property (nonatomic, retain) NSString * orderNumber;
@property (nonatomic, retain) NSNumber * quantityError;
@property (nonatomic, retain) Contract *contract;
@property (nonatomic, retain) NSSet *grns;
@property (nonatomic, retain) NSSet *lineItems;
@end

@interface PurchaseOrder (CoreDataGeneratedAccessors)

- (void)addGrnsObject:(GRN *)value;
- (void)removeGrnsObject:(GRN *)value;
- (void)addGrns:(NSSet *)values;
- (void)removeGrns:(NSSet *)values;

- (void)addLineItemsObject:(PurchaseOrderItem *)value;
- (void)removeLineItemsObject:(PurchaseOrderItem *)value;
- (void)addLineItems:(NSSet *)values;
- (void)removeLineItems:(NSSet *)values;

@end
