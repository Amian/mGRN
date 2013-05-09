//
//  M1XResponse.h
//  mgrn
//
//  Created by Peter Barclay on 20/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "M1XResponseHeader.h"

@interface M1XResponse : NSObject

#define M1XResponse_header @"header"
#define M1XResponse_body @"body"

@property (readonly, nonatomic) NSNumber *statusCode;
@property (readonly, nonatomic) BOOL valid;
@property (readonly, nonatomic) NSString *type;
@property (readonly, nonatomic) M1XResponseHeader *header;
@property (readonly, nonatomic) NSDictionary *body;

- (id)initWithResponseData:(NSData *)responseData andStatusCode:(int)statusCode;
- (id)initWithResponseData:(NSData *)responseData;

- (NSDictionary *)dictionaryValue;

- (NSString *)jsonValue;

@end
