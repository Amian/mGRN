//
//  GRN+Management.m
//  mgrn
//
//  Created by Peter on 21/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//

#import "PurchaseOrder+Management.h"
#import "GRNItem+Management.h"
#import "GRN+Management.h"

@implementation GRN (Management)

+ (GRN *)grnWithSDNRef:(NSString *)sdnRef forPurchaseOrder:(PurchaseOrder *)purchaseOrder inManagedObjectContext:(NSManagedObjectContext *)context error:(NSError **)error
{
    GRN *grn = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"GRN"];
    
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"supplierReference" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"supplierReference = %@", sdnRef];
    
    
    NSError *fetchError = nil;
    NSArray *matches = [context executeFetchRequest:request error:&fetchError];
    
    if (!matches || [matches count] > 0) {
        // TODO: set values for error
        if (error != NULL) {
            if (!matches){
                *error = [NSError errorWithDomain:@"fetcherror" code:0 userInfo:@{@"error":fetchError}];
            } else {
                *error = [NSError errorWithDomain:@"invalidsdn" code:0 userInfo:nil];
            }
        }
        return nil;
    } else {
        grn = [NSEntityDescription insertNewObjectForEntityForName:@"GRN" inManagedObjectContext:context];
        grn.supplierReference = sdnRef;
        grn.orderNumber = purchaseOrder.orderNumber;
        grn.deliveryDate = [[NSDate alloc] init];
        grn.notes = @"";
        
        [purchaseOrder addGrnsObject:grn];
        for (PurchaseOrderItem *poi in purchaseOrder.lineItems) {
            [GRNItem grnItemForGRN:grn withDataFromPurchaseOrderItem:poi inManagedObjectContext:context error:nil];
        }
        [context save:nil];
    }
    
    return grn;
}

+ (GRN *)grnForPurchaseOrder:(PurchaseOrder *)purchaseOrder inManagedObjectContext:(NSManagedObjectContext *)context error:(NSError **)error
{
    GRN *grn = nil;
    
    grn = [NSEntityDescription insertNewObjectForEntityForName:@"GRN" inManagedObjectContext:context];
    grn.orderNumber = purchaseOrder.orderNumber;
    grn.deliveryDate = [[NSDate alloc] init];
    grn.notes = @"";
    
    [purchaseOrder addGrnsObject:grn];
    for (PurchaseOrderItem *poi in purchaseOrder.lineItems) {
        [GRNItem grnItemForGRN:grn withDataFromPurchaseOrderItem:poi inManagedObjectContext:context error:nil];
    }
    [context save:nil];
    return grn;
}

+ (BOOL)grnExistsWithSDNRef:(NSString *)sdnRef inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"GRN"];
    
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"supplierReference" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"supplierReference = %@", sdnRef];
    
    
    NSError *fetchError = nil;
    NSArray *matches = [context executeFetchRequest:request error:&fetchError];
    
    if ([matches count] > 0) {
        return YES;
    } else {
        return NO;
    }
}

+(void)removeAllObjectsInManagedObjectContext:(NSManagedObjectContext*)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"GRN"];
    NSError *fetchError = nil;
    NSArray *matches = [context executeFetchRequest:request error:&fetchError];
    for (id o in matches)
    {
        [context deleteObject:o];
    }
    [context save:nil];
}
@end
