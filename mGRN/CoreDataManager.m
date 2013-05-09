//
//  CoreDataManager.m
//  mGRN
//
//  Created by Anum on 01/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "CoreDataManager.h"

@implementation CoreDataManager
@synthesize managedObjectContext;
static CoreDataManager *sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (CoreDataManager *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
    }
    
    return self;
}

// We don't want to allocate a new instance, so return the current one.
+ (id)allocWithZone:(NSZone*)zone {
    return [self sharedInstance];
}

// Equally, we don't want to generate multiple copies of the singleton.
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

+(void)removeAllContracts
{
    NSManagedObjectContext *context = [CoreDataManager sharedInstance].managedObjectContext;
    [Contract removeAllContractsInManagedObjectContext:context];
    [PurchaseOrder removeAllPurchaseOrdersInManagedObjectContext:context];
    [PurchaseOrderItem removeAllPurchaseOrdersItemsInManagedObjectContext:context];
    [WBS removeAllWBSInManagedObjectContext:context];
}

@end
