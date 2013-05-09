//
//  M1XRequestHeader.m
//  mgrn
//
//  Created by Peter Barclay on 20/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//


#import "M1XRequestHeader.h"

@implementation M1XRequestHeader

@synthesize domain = _domain;
@synthesize password = _password;
@synthesize role = _role;
@synthesize sessionEndDT = _sessionEndDT;
@synthesize transactionId = _transactionId;
@synthesize userId = _userId;

- (NSString *)transactionId
{
    if (!_transactionId) {
        _transactionId = [self createUUID];
    }
    return _transactionId;
}

- (NSDictionary *)dictionaryValue
{
    NSMutableDictionary *headerDict = [NSMutableDictionary dictionary];
    [headerDict setValue:self.domain forKey:M1XRequestHeader_domain];
    [headerDict setValue:self.password forKey:M1XRequestHeader_password];
    [headerDict setValue:self.role forKey:M1XRequestHeader_role];
    [headerDict setValue:self.sessionEndDT forKey:M1XRequestHeader_sessionEndDT];
    [headerDict setValue:self.transactionId forKey:M1XRequestHeader_transactionID];
    [headerDict setValue:self.userId forKey:M1XRequestHeader_userID];
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
    NSMutableString *desc = [NSMutableString string];
    [desc appendString:@"{"];
    [desc appendFormat:@"\%@: %@",M1XRequestHeader_domain,self.domain];
    [desc appendFormat:@"\%@: %@",M1XRequestHeader_password,self.password];
    [desc appendFormat:@"\%@: %@",M1XRequestHeader_role,self.role];
    [desc appendFormat:@"\%@: %@",M1XRequestHeader_sessionEndDT,self.sessionEndDT];
    [desc appendFormat:@"\%@: %@",M1XRequestHeader_transactionID,self.transactionId];
    [desc appendFormat:@"\%@: %@",M1XRequestHeader_userID,self.userId];
    [desc appendString:@"\n}"];
    return [NSString stringWithString:desc];
}

- (NSString *)createUUID
{
    // Create universally unique identifier (object)
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    
    // Get the string representation of CFUUID object.
    NSString *uuidStr = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidObject));
    
    // If needed, here is how to get a representation in bytes, returned as a structure
    // typedef struct {
    //   UInt8 byte0;
    //   UInt8 byte1;
    //   ...
    //   UInt8 byte15;
    // } CFUUIDBytes;
    //CFUUIDBytes bytes = CFUUIDGetUUIDBytes(uuidObject);    
    
    return uuidStr;
}

@end
