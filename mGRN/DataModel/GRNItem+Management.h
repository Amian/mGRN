//
//  GRNItem+Management.h
//  mgrn
//
//  Created by Peter on 21/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//

#import "GRNItem.h"

#define M1XGRNItem_Exception @"exception"

@interface GRNItem (Management)

+ (GRNItem *)grnItemForGRN:(GRN *)grn withDataFromPurchaseOrderItem:(PurchaseOrderItem *)purchaseOrderItem inManagedObjectContext:(NSManagedObjectContext *)context error:(NSError **)error;
+(GRNItem*)fetchItemWithNumber:(NSString*)number moc:(NSManagedObjectContext*)context error:(NSError**)error;
+(void)removeAllObjectsInManagedObjectContext:(NSManagedObjectContext*)context;

@end
