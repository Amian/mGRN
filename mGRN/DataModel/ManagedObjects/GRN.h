//
//  GRN.h
//  mgrn
//
//  Created by Peter on 23/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GRNItem, PurchaseOrder;

@interface GRN : NSManagedObject

@property (nonatomic, retain) NSDate * deliveryDate;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * orderNumber;
@property (nonatomic, retain) NSString * photo1URI;
@property (nonatomic, retain) NSString * photo2URI;
@property (nonatomic, retain) NSString * photo3URI;
@property (nonatomic, retain) NSString * signatureURI;
@property (nonatomic, retain) NSString * supplierReference;
@property (nonatomic, retain) NSSet *lineItems;
@property (nonatomic, retain) PurchaseOrder *purchaseOrder;
@end

@interface GRN (CoreDataGeneratedAccessors)

- (void)addLineItemsObject:(GRNItem *)value;
- (void)removeLineItemsObject:(GRNItem *)value;
- (void)addLineItems:(NSSet *)values;
- (void)removeLineItems:(NSSet *)values;

@end
