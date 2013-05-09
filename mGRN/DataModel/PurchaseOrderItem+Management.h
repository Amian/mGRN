//
//  PurchaseOrderItem+Management.h
//  mgrn
//
//  Created by Peter on 21/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//

#import "PurchaseOrder+Management.h"
#import "PurchaseOrderItem.h"

#define M1XPurchaseOrderItem_DueDate @"dueDate"
#define M1XPurchaseOrderItem_DueDateSpecified @"dueDateSpecified"
#define M1XPurchaseOrderItem_ItemDescription @"description"
#define M1XPurchaseOrderItem_ExtraDescription @"extraDescription"
#define M1XPurchaseOrderItem_ItemNumber @"itemNumber"
#define M1XPurchaseOrderItem_QtyBalance @"quantityBalance"
#define M1XPurchaseOrderItem_Uoq @"uoq"
#define M1XPurchaseOrderItem_Plant @"plant"
#define M1XPurchaseOrderItem_WBSCode @"code"

@interface PurchaseOrderItem (Management)

+ (PurchaseOrderItem *)insertPurchaseOrderItemWithData:(NSDictionary *)purchaseOrderItemData forPurchaseOrder:(PurchaseOrder *)purchaseOrder inManagedObjectContext:(NSManagedObjectContext *)context error:(NSError **)error;
+(NSArray*)fetchPurchaseOrdersItemsForOrderNumber:(NSString*)orderNumber inMOC:(NSManagedObjectContext*)moc;
+(void)removeAllPurchaseOrdersItemsInManagedObjectContext:(NSManagedObjectContext*)context;

@end
