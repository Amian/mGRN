//
//  PurchaseOrder+Management.h
//  mgrn
//
//  Created by Peter on 21/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//

#import "Contract+Management.h"
#import "PurchaseOrder.h"

#define M1XPurchaseOrder_OrderNumber @"PurchaseOrderNumber"
#define M1XPurchaseOrder_SupplierName @"PurchaseOrderName"
#define M1XPurchaseOrder_Description @"PurchaseOrderDescription"
#define M1XPurchaseOrder_Attention @"Attention"
#define M1XPurchaseOrder_AttentionPhone @"AttentionPhone"
#define M1XPurchaseOrder_QuantityError @"QuantityError"
#define M1XPurchaseOrder_LineItems @"lineItems"

@interface PurchaseOrder (Management)

+ (PurchaseOrder *)insertPurchaseOrderWithData:(NSDictionary *)purchaseOrderData forContract:(Contract *)contract inManagedObjectContext:(NSManagedObjectContext *)context error:(NSError **)error;
+ (NSArray*)fetchPurchaseOrdersForContractNumber:(NSString*)contractNumber inMOC:(NSManagedObjectContext*)moc;
+(void)removeAllPurchaseOrdersInManagedObjectContext:(NSManagedObjectContext*)context;
@end
