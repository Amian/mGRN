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
#import "M1XmGRNService.h"

@interface CoreDataManager : NSObject <M1XmGRNDelegate>
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property BOOL processing;
+ (CoreDataManager*)sharedInstance;
+(void)removeAllContracts;
 -(void)submitGRN;
+(void)clearAllDataOnLogout;
+(void)getAllDataInBG;
+(void)removeAllSDNs;
+(NSManagedObjectContext*)moc;
@end
