//
//  Contract+Management.h
//  mgrn
//
//  Created by Peter Barclay on 20/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//

#import "Contract.h"

#define M1XContract_Number @"ContractNumber"
#define M1XContract_Name @"ContractName"
#define M1XContract_UseWBS @"useWBS"
#define M1XContract_WBSCodes @"wbsCodes"

@interface Contract (Management)

+ (Contract *)insertContractWithData:(NSDictionary *)contractData inManagedObjectContext:(NSManagedObjectContext *)context error:(NSError **)error;
+(NSArray*)fetchAllContractsInManagedObjectContext:(NSManagedObjectContext*)context;
+(void)removeAllContractsInManagedObjectContext:(NSManagedObjectContext*)context;
+(int)contractCountInMOC:(NSManagedObjectContext*)moc;
@end
