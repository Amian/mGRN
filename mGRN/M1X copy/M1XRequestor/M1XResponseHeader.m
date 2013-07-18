//
//  M1XResponseHeader.m
//  mgrn
//
//  Created by Peter Barclay on 20/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//


#import "M1XResponseHeader.h"

@implementation M1XResponseHeader

@synthesize exception = _exception;
@synthesize notifications = _notifications;
@synthesize success = _success;
@synthesize transactionId = _transactionId;

- (id)initWithDictionary:(NSDictionary *)headerDictionary
{
    if (self = [super init]) {
        NSDictionary *exception = [headerDictionary valueForKey:M1XResponseHeader_exception];
        if (exception) {
            self->_exception = [[M1XResponseHeaderException alloc] initWithDictionary:exception];
        }
        self->_notifications = [headerDictionary valueForKey:M1XResponseHeader_notifications];
        self->_success = [[headerDictionary valueForKey:M1XResponseHeader_success] boolValue];
        self->_transactionId = [headerDictionary valueForKey:M1XResponseHeader_transactionId];
    }
    return self;    
}

- (NSDictionary *)dictionaryValue
{
    NSMutableDictionary *headerDict = [NSMutableDictionary dictionary];
    [headerDict setValue:[self.exception dictionaryValue] forKey:M1XResponseHeader_exception];
    [headerDict setValue:self.notifications forKey:M1XResponseHeader_notifications];
    [headerDict setValue:[NSNumber numberWithBool:self.success] forKey:M1XResponseHeader_success];
    [headerDict setValue:self.transactionId forKey:M1XResponseHeader_transactionId];
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
    [desc appendFormat:@"\n\tException: {\n%@\n}", self.exception];
    [desc appendFormat:@"\n\tNotifications[%d]: %@", [self.notifications count],self.notifications];
    [desc appendFormat:@"\n\tSuccess: %@",self.success ? @"YES" : @"NO"];
    [desc appendFormat:@"\n\tTransactionID: %@", self.transactionId];
    return desc;
}

@end
