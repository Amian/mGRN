//
//  M1XRequestHeader.h
//  mgrn
//
//  Created by Peter Barclay on 20/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface M1XRequestHeader : NSObject

//#define M1XRequestHeader_appName @"applicationName"
//#define M1XRequestHeader_appVersion @"applicationVersion"
#define M1XRequestHeader_domain @"domain"
#define M1XRequestHeader_password @"password"
#define M1XRequestHeader_role @"role"
#define M1XRequestHeader_sessionEndDT @"sessionEndDT"
//#define M1XRequestHeader_sessionKey @"sessionKey"
#define M1XRequestHeader_transactionID @"transactionId"
#define M1XRequestHeader_userID @"userId"

@property (strong, nonatomic) NSString *domain;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *role;
@property (strong, nonatomic) NSString *sessionEndDT;
@property (strong, nonatomic) NSString *transactionId;
@property (strong, nonatomic) NSString *userId;

- (NSDictionary *)dictionaryValue;

- (NSString *)jsonValue;

@end
