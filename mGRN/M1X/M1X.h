//
//  M1X.h
//  mgrn
//
//  Created by Peter on 20/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//

#import "M1XRequestor.h"
#import <Foundation/Foundation.h>

typedef enum
{
    M1xExceptionNone,
    M1xExceptionNoInternetConnection,
    M1xExceptionNoSuccess,
    M1xExceptionAuthenticationFailed
}M1xException;

@interface M1XSession : NSObject

@property (strong, nonatomic) NSString *domain;
//@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *sessionKey;
@property (strong, nonatomic) NSString *sessionEndDT;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *kco;

@end

@interface M1XServiceConnection : NSObject

@property (nonatomic, strong) NSString *port;
@property (nonatomic, strong) NSString *server;
@property (nonatomic, strong) NSString *serviceName;

@end

// ------------------------------------------

@protocol M1XDelegate <NSObject>

@optional

- (void)onNewSessionSuccess:(M1XSession *)session;
- (void)onServiceConnectionSuccess:(M1XServiceConnection *)service;
- (void)onNewSessionFailure:(M1XResponse *)response exceptionType:(M1xException)exception;

@end

// ------------------------------------------

@interface M1X : NSObject <M1XRequestorDelegate>

@property (strong, nonatomic) id <M1XDelegate> delegate;
@property (strong, nonatomic) NSString *systemURL;

- (void)newSessionForAppName:(NSString *)appName withHeader:(M1XRequestHeader *)header;
- (void)FetchServiceConnectionDetailsForAppName:(NSString *)appName withHeader:(M1XRequestHeader *)header;

@end
