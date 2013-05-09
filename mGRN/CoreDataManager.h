//
//  CoreDataManager.h
//  mGRN
//
//  Created by Anum on 01/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBS+Management.h"
#import "PurchaseOrder+Management.h"
#import "PurchaseOrderItem+Management.h"
#import "Contract+Management.h"
@interface CoreDataManager : NSObject
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
+ (CoreDataManager*)sharedInstance;
+(void)removeAllContracts;
@end
