//
//  M1XResponseHeader.h
//  mgrn
//
//  Created by Peter Barclay on 20/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "M1XResponseHeaderException.h"

@interface M1XResponseHeader : NSObject

#define M1XResponseHeader_exception @"exception"
#define M1XResponseHeader_notifications @"notifications"
#define M1XResponseHeader_success @"success"
#define M1XResponseHeader_transactionId @"transactionId"

@property (readonly, nonatomic) M1XResponseHeaderException *exception;
@property (readonly, nonatomic) NSArray *notifications;
@property (readonly) BOOL success;
@property (readonly, nonatomic) NSString *transactionId;

- (id)initWithDictionary:(NSDictionary *)headerDictionary;

- (NSDictionary *)dictionaryValue;

- (NSString *)jsonValue;

@end