//
//  GRNM1XHeader.m
//  mGRN
//
//  Created by Anum on 01/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNM1XHeader.h"

@implementation GRNM1XHeader

+(M1XRequestHeader*)GetHeader
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    M1XRequestHeader *header = [[M1XRequestHeader alloc] init];
    header.userId = [userDefaults objectForKey:KeyUserID];
    header.password = [userDefaults objectForKey:KeyPassword];
    header.domain = [userDefaults objectForKey:KeyDomainName];
    header.role = [userDefaults objectForKey:KeyRole];
    header.transactionId = [userDefaults objectForKey:KeyTransactionID];
    header.sessionEndDT = [userDefaults objectForKey:KeySessionEndDate];
    return header;
}

@end
