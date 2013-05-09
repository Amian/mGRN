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
    request.predicate = [NSPredicate predicateWithFormat:@"grn.supplierReference = %@ AND itemNumber = %@", grn.supplierReference, purchaseOrderItem.itemNumber];
    
    
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
            grnItem = [matches objectAtIndex:0];
//            NSLog(@"Match found for GRN %@ for %@", grn.supplierReference, purchaseOrderItem.purchaseOrder.orderNumber);
        } else {
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
            [context save:nil];
//            NSLog(@"Created GRN %@ for %@", grn.supplierReference, purchaseOrderItem.purchaseOrder.orderNumber);
        }
    }
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

@end
