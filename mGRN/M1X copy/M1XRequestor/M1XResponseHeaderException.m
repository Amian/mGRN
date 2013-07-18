//
//  M1XResponseHeaderException.m
//  mgrn
//
//  Created by Peter Barclay on 20/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//

#import "M1XResponseHeaderException.h"

@implementation M1XResponseHeaderException

@synthesize message = _message;
@synthesize source = _source;
@synthesize thrownAt = _thrownAt;

- (id)initWithDictionary:(NSDictionary *)headerDictionary
{
    if (self = [super init]) {
        self->_message = [headerDictionary valueForKey:M1XRequestHeaderExceptoin_message];
        self->_source = [headerDictionary valueForKey:M1XRequestHeaderExceptoin_source];
        self->_thrownAt = [headerDictionary valueForKey:M1XRequestHeaderExceptoin_thrownAt];;
    }
    return self;    
}

- (NSDictionary *)dictionaryValue
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.message forKey:M1XRequestHeaderExceptoin_message];
    [dict setValue:self.source forKey:M1XRequestHeaderExceptoin_source];
    [dict setValue:self.thrownAt forKey:M1XRequestHeaderExceptoin_thrownAt];
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (NSString *)jsonValue
{
    NSString *jsonStr = nil;
    NSError *jsonError = nil;
    @try {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self dictionaryValue] options:kNilOptions error:&jsonError];
        if (jsonData) {
            jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        } else {
// TODO: handle errors via delegate
        }
    }
    @catch(NSException *ex) {
// TODO: handle exceptions via delegate
    }
    return jsonStr;
}

- (NSString *)description
{
    NSString *desc = [NSString stringWithFormat:@"[%@] %@\n(%@)", self.source, self.message, self.thrownAt]; 
    return desc;
}

@end
