//
//  GRN+Management.h
//  mgrn
//
//  Created by Peter on 21/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//

#import "GRN.h"

#define M1XGRNSubmissionResponse_grnNumber @"mGRNNumber"
#define M1XGRNSubmissionResponse_sdnRef @"supplierReference"

@interface GRN (Management)

+ (GRN *)grnWithSDNRef:(NSString *)sdnRef forPurchaseOrder:(PurchaseOrder *)purchaseOrder inManagedObjectContext:(NSManagedObjectContext *)context error:(NSError **)error;
+ (BOOL)grnExistsWithSDNRef:(NSString *)sdnRef inManagedObjectContext:(NSManagedObjectContext *)context;
+ (GRN *)grnForPurchaseOrder:(PurchaseOrder *)purchaseOrder inManagedObjectContext:(NSManagedObjectContext *)context error:(NSError **)error;
+(void)removeAllObjectsInManagedObjectContext:(NSManagedObjectContext*)context;
+(NSArray*)fetchSubmittedGRNInMOC:(NSManagedObjectContext*)moc;

@end
