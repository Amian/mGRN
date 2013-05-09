//
//  PurchaseOrder+Management.m
//  mgrn
//
//  Created by Peter on 21/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//

#import "PurchaseOrder+Management.h"

@implementation PurchaseOrder (Management)

+ (PurchaseOrder *)insertPurchaseOrderWithData:(NSDictionary *)purchaseOrderData forContract:(Contract *)contract inManagedObjectContext:(NSManagedObjectContext *)context error:(NSError **)error;
{
    PurchaseOrder *purchaseOrder = nil;
    
    if (purchaseOrderData == nil) {
        if (error != NULL) {
// TODO: set values for error
            *error = [NSError errorWithDomain:@"" code:0 userInfo:nil];;
        }
        return nil;
    } else {
        NSString *orderNumber = [[purchaseOrderData valueForKey:M1XPurchaseOrder_OrderNumber] description];
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"PurchaseOrder"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"orderNumber" ascending:YES]];
        request.predicate = [NSPredicate predicateWithFormat:@"contract.number = %@ and orderNumber = %@", contract.number, orderNumber];
        
        NSError *fetchError = nil;
        NSArray *matches = [context executeFetchRequest:request error:&fetchError];
        
        if (!matches || [matches count] > 1) {
// TODO: set values for error
            if (error != NULL) {
                *error = [NSError errorWithDomain:@"" code:0 userInfo:nil];;
            }
            return nil;
        } else {
            if ([matches count] == 1) {
                purchaseOrder = [matches objectAtIndex:0];
//                NSLog(@"Match found for PO %@: %@", purchaseOrder.orderNumber, purchaseOrder.orderDescription);
            } else {
                purchaseOrder = [NSEntityDescription insertNewObjectForEntityForName:@"PurchaseOrder" inManagedObjectContext:context];
                purchaseOrder.orderNumber = [[purchaseOrderData valueForKey:M1XPurchaseOrder_OrderNumber] description];
                purchaseOrder.orderDescription = [[purchaseOrderData valueForKey:M1XPurchaseOrder_Description] description];
                purchaseOrder.orderName = [[purchaseOrderData valueForKey:M1XPurchaseOrder_SupplierName] description];
                purchaseOrder.attention = [[purchaseOrderData valueForKey:M1XPurchaseOrder_Attention] description];
                purchaseOrder.attentionPhone = [[purchaseOrderData valueForKey:M1XPurchaseOrder_AttentionPhone] description];
                purchaseOrder.quantityError = (NSNumber *)[purchaseOrderData valueForKey:M1XPurchaseOrder_QuantityError];

                [contract addPurchaseOrdersObject:purchaseOrder];
                [context save:nil];
//                NSLog(@"created PO %@: %@", purchaseOrder.orderNumber, purchaseOrder.orderDescription);
            }
        }
    }
    return purchaseOrder;
}

+(NSArray*)fetchPurchaseOrdersForContractNumber:(NSString*)contractNumber inMOC:(NSManagedObjectContext*)moc
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"PurchaseOrder"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"orderNumber" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"contract.number = %@", contractNumber];
    
    NSError *fetchError = nil;
    NSArray *matches = [moc executeFetchRequest:request error:&fetchError];
    return matches? matches : [NSArray array];
}

+(void)removeAllPurchaseOrdersInManagedObjectContext:(NSManagedObjectContext*)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"PurchaseOrder"];
    NSError *fetchError = nil;
    NSArray *matches = [context executeFetchRequest:request error:&fetchError];
    for (id o in matches)
    {
        [context deleteObject:o];
    }
    [context save:nil];
}

@end
