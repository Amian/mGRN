//
//  M1XRequest.h
//  mgrn
//
//  Created by Peter Barclay on 20/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//


#import "M1XRequest.h"

@implementation M1XRequest

@synthesize header = _header;
@synthesize body = _body;

- (NSMutableDictionary *)body
{
    if (!_body) {
        _body = [[NSMutableDictionary alloc] init];
    }
    return _body;
}

- (NSDictionary *)dictionaryValue
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[self.header dictionaryValue] forKey:M1XRequest_header];
    [dict setValue:self.body forKey:M1XRequest_body];
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (NSString *)jsonValue
{
    NSString *jsonStr = nil;
    NSError *jsonError = nil;
    NSLog(@"request = %@",[self dictionaryValue]);
    if ([NSJSONSerialization isValidJSONObject:[self dictionaryValue]])
        NSLog(@"is json");
    
    
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
    return [self jsonValue];
}

@end
