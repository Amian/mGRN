//
//  M1X.h
//  mgrn
//
//  Created by Peter on 20/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//

#import "M1XRequestor.h"
#import <Foundation/Foundation.h>


@interface M1XSession : NSObject

@property (strong, nonatomic) NSString *domain;
//@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *sessionKey;
@property (strong, nonatomic) NSString *sessionEndDT;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *kco;

@end

// ------------------------------------------

@protocol M1XDelegate <NSObject>

@optional

- (void)onNewSessionSuccess:(M1XSession *)session;
- (void)onNewSessionFailure:(M1XResponse *)response;

@end

// ------------------------------------------

@interface M1X : NSObject <M1XRequestorDelegate>

@property (strong, nonatomic) id <M1XDelegate> delegate;
@property (strong, nonatomic) NSString *systemURL;

- (void)newSessionForAppName:(NSString *)appName withHeader:(M1XRequestHeader *)header;

@end
