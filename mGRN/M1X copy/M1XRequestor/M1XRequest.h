//
//  M1XRequest.h
//  mgrn
//
//  Created by Peter Barclay on 20/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M1XRequestHeader.h"

@interface M1XRequest : NSObject

#define M1XRequest_header @"header"
#define M1XRequest_body @"body"

@property (strong, nonatomic) M1XRequestHeader *header;
@property (strong, nonatomic) NSMutableDictionary *body;

- (NSDictionary *)dictionaryValue;

- (NSString *)jsonValue;

@end
