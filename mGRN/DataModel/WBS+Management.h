//
//  WBS+Management.h
//  mgrn
//
//  Created by Peter on 21/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//

#import "WBS.h"

#define M1XWBS_Code @"code"
#define M1XWBS_Description @"description"

@interface WBS (Management)
+(void)removeAllWBSInManagedObjectContext:(NSManagedObjectContext*)context;
+(NSArray*)fetchWBSCodesForContractNumber:(NSString*)contractNumber inMOC:(NSManagedObjectContext*)moc;
+ (WBS *)insertWBSCodesWithData:(NSDictionary *)wbsData forContract:(Contract *)contract inManagedObjectContext:(NSManagedObjectContext *)context error:(NSError **)error;
@end
