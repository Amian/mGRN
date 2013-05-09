//
//  PurchaseOrderItem+Management.m
//  mgrn
//
//  Created by Peter on 21/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//

#import "PurchaseOrderItem+Management.h"

@implementation PurchaseOrderItem (Management)

+ (PurchaseOrderItem *)insertPurchaseOrderItemWithData:(NSDictionary *)purchaseOrderItemData forPurchaseOrder:(PurchaseOrder *)purchaseOrder inManagedObjectContext:(NSManagedObjectContext *)context error:(NSError **)error;
{
    PurchaseOrderItem *purchaseOrderItem = nil;
    
    if (purchaseOrderItemData == nil) {
        if (error != NULL) {
// TODO: set values for error
            *error = [NSError errorWithDomain:@"" code:0 userInfo:nil];;
        }
        return nil;
    } else {
        NSString *itemNumber = [[purchaseOrderItemData valueForKey:M1XPurchaseOrderItem_ItemNumber] description];

        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"PurchaseOrderItem"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"itemNumber" ascending:YES]];
        request.predicate = [NSPredicate predicateWithFormat:@"purchaseOrder.orderNumber = %@ AND itemNumber = %@",purchaseOrder.orderNumber, itemNumber];
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
                purchaseOrderItem = [matches objectAtIndex:0];
//                NSLog(@"Match found for POI %@: %@", purchaseOrderItem.itemNumber, purchaseOrderItem.itemDescription );
            } else {

                purchaseOrderItem = [NSEntityDescription insertNewObjectForEntityForName:@"PurchaseOrderItem" inManagedObjectContext:context];
                purchaseOrderItem.itemNumber = [[[purchaseOrderItemData valueForKey:M1XPurchaseOrderItem_ItemNumber] description] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                purchaseOrderItem.itemDescription = [[purchaseOrderItemData valueForKey:M1XPurchaseOrderItem_ItemDescription] description];
// TODO: convert date string
//                purchaseOrderItem.dueDate = [[purchaseOrderItemData valueForKey:M1XPurchaseOrderItem_DeliveryDate] description];
                purchaseOrderItem.dueDateSpecified = (NSNumber *)[purchaseOrderItemData valueForKey:M1XPurchaseOrderItem_DueDateSpecified];
                purchaseOrderItem.quantityBalance = (NSNumber *)[purchaseOrderItemData valueForKey:M1XPurchaseOrderItem_QtyBalance];
//                purchaseOrderItem.quantityClass = [[purchaseOrderData valueForKey:M1XPurchaseOrderItem_QtyClass] description];
                purchaseOrderItem.uoq = [[purchaseOrderItemData valueForKey:M1XPurchaseOrderItem_Uoq] description];
                purchaseOrderItem.wbsCode = [[purchaseOrderItemData valueForKey:M1XPurchaseOrderItem_WBSCode] description];
//                NSLog(@"Created POI %@ for %@", purchaseOrderItem.itemNumber, purchaseOrder.orderNumber);
            }
            [purchaseOrder addLineItemsObject:purchaseOrderItem];
            [context save:nil];
        }
    }
    return purchaseOrderItem;
}

+(NSArray*)fetchPurchaseOrdersItemsForOrderNumber:(NSString*)orderNumber inMOC:(NSManagedObjectContext*)moc
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"PurchaseOrderItem"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"itemNumber" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"purchaseOrder.orderNumber = %@", orderNumber];
    
    NSError *fetchError = nil;
    NSArray *matches = [moc executeFetchRequest:request error:&fetchError];
    return matches? matches : [NSArray array];
    
}

+(void)removeAllPurchaseOrdersItemsInManagedObjectContext:(NSManagedObjectContext*)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"PurchaseOrderItem"];
    NSError *fetchError = nil;
    NSArray *matches = [context executeFetchRequest:request error:&fetchError];
    for (id o in matches)
    {
        [context deleteObject:o];
    }
    [context save:nil];
}
@end
