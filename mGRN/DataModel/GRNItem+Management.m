//
//  GRNItem+Management.m
//  mgrn
//
//  Created by Peter on 21/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//

#import "PurchaseOrder+Management.h"
#import "PurchaseOrderItem+Management.h"
#import "GRN+Management.h"
#import "GRNItem+Management.h"

@implementation GRNItem (Management)

+ (GRNItem *)grnItemForGRN:(GRN *)grn withDataFromPurchaseOrderItem:(PurchaseOrderItem *)purchaseOrderItem inManagedObjectContext:(NSManagedObjectContext *)context error:(NSError **)error
{
    GRNItem *grnItem = nil;
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"GRNItem"];
    
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"itemNumber" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"itemNumber = %@ AND grn.purchaseOrder.orderNumber = %@", purchaseOrderItem.itemNumber, purchaseOrderItem.purchaseOrder.orderNumber];
    
    
    NSError *fetchError = nil;
    NSArray *matches = [context executeFetchRequest:request error:&fetchError];
    
    if ([matches count] > 0)
    {
        //TODO: Do we need to do anything about this?
//        for (id item in matches)
//        {
//            [context deleteObject:item];
//        }
    }
    grnItem = [NSEntityDescription insertNewObjectForEntityForName:@"GRNItem" inManagedObjectContext:context];
    grnItem.itemNumber = purchaseOrderItem.itemNumber;
    grnItem.notes = nil;
    grnItem.exception = nil;
    grnItem.quantityDelivered = purchaseOrderItem.quantityBalance;
    grnItem.quantityRejected = [NSNumber numberWithInt:0];
    grnItem.serialNumber = nil;
    grnItem.uoq = purchaseOrderItem.uoq;
    grnItem.wbsCode = purchaseOrderItem.wbsCode;
    grnItem.exception = @"";
    
    [grn addLineItemsObject:grnItem];
    //            NSLog(@"Created GRN %@ for %@", grn.supplierReference, purchaseOrderItem.purchaseOrder.orderNumber);
    return grnItem;
}

+(GRNItem*)fetchItemWithNumber:(NSString*)number moc:(NSManagedObjectContext*)context error:(NSError**)error
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"GRNItem"];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"itemNumber" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"itemNumber = %@", number];
    NSError *fetchError = nil;
    NSArray *matches = [context executeFetchRequest:request error:&fetchError];
    
    if (!matches || [matches count] > 1) {
        // TODO: set values for error
        if (error != NULL) {
            *error = [NSError errorWithDomain:@"" code:0 userInfo:nil];;
        }
    }
    return [matches lastObject];
}


+(void)removeAllObjectsInManagedObjectContext:(NSManagedObjectContext*)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"GRNItem"];
    NSError *fetchError = nil;
    NSArray *matches = [context executeFetchRequest:request error:&fetchError];
    for (id o in matches)
    {
        [context deleteObject:o];
    }
}

@end
