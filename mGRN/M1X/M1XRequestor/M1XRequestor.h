//
//  M1XRequestor.h
//  SimplifiedDataRequests
//  mgrn
//
//  Created by Peter Barclay on 20/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "M1XRequest.h"
#import "M1XResponse.h"
#import "M1XRequestorDelegate.h"

@interface M1XRequestor : NSObject

@property (strong, nonatomic) id <M1XRequestorDelegate> delegate;
@property (strong, nonatomic) M1XRequest *request;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) M1XResponse *response;

// Designated Inititiliser
- (id)initWithDelegate:(id)delegate;

- (void)send;
- (void)clearResponse;

+ (NSString*)sendSyncronousRequest:(M1XRequest*)newRequest withURL:(NSURL*)newURL;

@end
