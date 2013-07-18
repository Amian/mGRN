//
//  M1XResponseHeaderException.h
//  mgrn
//
//  Created by Peter Barclay on 20/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface M1XResponseHeaderException : NSObject


#define M1XRequestHeaderExceptoin_message @"message"
#define M1XRequestHeaderExceptoin_source @"source"
#define M1XRequestHeaderExceptoin_thrownAt @"thrownAt"

@property (readonly, nonatomic) NSString *message;
@property (readonly, nonatomic) NSString *source;
@property (readonly, nonatomic) NSString *thrownAt;

- (id)initWithDictionary:(NSDictionary *)headerDictionary;

- (NSDictionary *)dictionaryValue;

- (NSString *)jsonValue;

@end
