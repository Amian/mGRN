//
//  M1XResponse.m
//  mgrn
//
//  Created by Peter Barclay on 20/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//


#import "M1XResponse.h"

@implementation M1XResponse

@synthesize statusCode = _statusCode;
@synthesize valid = _valid;
@synthesize header = _header;
@synthesize body = _body;

- (id)initWithResponseData:(NSData *)responseData andStatusCode:(int)statusCode
{
    if (self = [super init]) {
        
        NSError *jsonError = nil;
        NSDictionary *jsonDict = nil;
        @try {
            NSLog(@"Response String = %@",[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
            jsonDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                       options:kNilOptions
                                                         error:&jsonError];
            
        }
        @catch(NSException *jsonEx) {
// TODO: use delegate to handle exceptions
            NSLog(@"JSON Exception: %@", jsonEx);
        }
        if (!jsonDict) {
// TODO: use delegate to handle errors
            NSLog(@"JSON Error: %@", jsonError);
            self->_statusCode = [NSNumber numberWithInt:statusCode];
            self->_valid = NO;
        } else {
            self->_valid = YES;
//            NSLog(@"Response Header: %@", [[M1XResponseHeader alloc] initWithDictionary:[jsonDict objectForKey:M1XResponse_header]]);
            self->_header = [[M1XResponseHeader alloc] initWithDictionary:[jsonDict objectForKey:M1XResponse_header]];
//            NSLog(@"Response Body: %@", [jsonDict objectForKey:M1XResponse_body]);
            self->_body = [jsonDict objectForKey:M1XResponse_body];
        }
    }
    return self;
}

- (id)initWithResponseData:(NSData *)responseData
{
    return [self initWithResponseData:responseData andStatusCode:0];
}

- (NSDictionary *)dictionaryValue
{
    NSMutableDictionary *headerDict = [NSMutableDictionary dictionary];
    [headerDict setValue:[self.header dictionaryValue] forKey:M1XResponse_header];
    [headerDict setValue:self.body forKey:M1XResponse_body];
    return [NSDictionary dictionaryWithDictionary:headerDict];
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
    return [self jsonValue];
}

@end
