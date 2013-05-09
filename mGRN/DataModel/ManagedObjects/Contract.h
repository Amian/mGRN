//
//  Contract.h
//  mgrn
//
//  Created by Peter on 23/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Company, PurchaseOrder, WBS;

@interface Contract : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSNumber * useWBS;
@property (nonatomic, retain) Company *company;
@property (nonatomic, retain) NSSet *purchaseOrders;
@property (nonatomic, retain) NSSet *wbsCodes;
@end

@interface Contract (CoreDataGeneratedAccessors)

- (void)addPurchaseOrdersObject:(PurchaseOrder *)value;
- (void)removePurchaseOrdersObject:(PurchaseOrder *)value;
- (void)addPurchaseOrders:(NSSet *)values;
- (void)removePurchaseOrders:(NSSet *)values;

- (void)addWbsCodesObject:(WBS *)value;
- (void)removeWbsCodesObject:(WBS *)value;
- (void)addWbsCodes:(NSSet *)values;
- (void)removeWbsCodes:(NSSet *)values;

@end
