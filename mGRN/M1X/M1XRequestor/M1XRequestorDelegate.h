//
//  M1XRequestorDelegate.h
//  mgrn
//
//  Created by Peter Barclay on 20/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "M1XResponse.h"

@protocol M1XRequestorDelegate <NSObject>

@optional

- (void)onM1XResponse:(M1XResponse *)response forRequest:(M1XRequest *)request;
- (void)onConnectionFailure;
- (void)onAlreadyWaitingForResponse;
@end
