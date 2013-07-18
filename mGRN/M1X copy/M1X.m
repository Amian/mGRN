//
//  M1X.m
//  mgrn
//
//  Created by Peter on 20/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//

#import "M1XRequestor.h"
#import "M1X.h"

#define M1xSystemService @"m1xsystemservice.svc"
#define M1xSystemService_newSession @"newsession"
#define M1xSystemService_fetchServiceConnectionDetails @"fetchserviceconnectiondetails"
#define M1XSystemService_NewSession_body_appName @"applicationName"

@interface M1XSession ()

@property (strong, nonatomic) M1XRequestor *systemServiceRequestor;

@end

@implementation M1XSession

@synthesize domain = _domain;
//@synthesize password = _password;
@synthesize sessionKey = _sessionKey;
@synthesize sessionEndDT = _sessionEndDT;
@synthesize userId = _userId;
@synthesize kco = _kco;

@end

// ------------------------------------------

@interface M1X ()

@property (strong, nonatomic) M1XRequestor *systemServiceRequestor;

@end

@implementation M1X

@synthesize systemURL = _systemURL;
@synthesize systemServiceRequestor = _systemServiceRequestor;

-(NSString *)systemURL
{
    if (!_systemURL) {
// TODO:: set this default from settings bundle?
        _systemURL = @"https://m1xdev.pervasic.com:29999";
    }
    return _systemURL;
}

- (M1XRequestor *)systemServiceRequestor
{
    if (!_systemServiceRequestor) {
        _systemServiceRequestor = [[M1XRequestor alloc] initWithDelegate:self];
    }
    return _systemServiceRequestor;
}

- (void)onM1XResponse:(M1XResponse *)response forRequest:(M1XRequest *)request
{
    BOOL failed = NO;
    if (self.delegate) {
        if (response.header.success) {
            if ([[response.body valueForKey:@"userAuthenticated"] boolValue]) {
                if ([self.delegate respondsToSelector:@selector(onNewSessionSuccess:)]) {
                    M1XSession *session = [[M1XSession alloc] init];
                    session.domain = request.header.domain;
                  //session.password = [response.body valueForKey:@"password"];
                    session.sessionKey = [response.body valueForKey:@"passKey"];
                    session.sessionEndDT = [response.body valueForKey:@"sessionEndDT"];
                    session.userId = request.header.userId;
                    session.kco = [response.body valueForKey:@"kco"];
                    [self.delegate onNewSessionSuccess:session];
                }
            } else {
                failed = YES;
            }
        } else {
            failed = YES;
        }
        if (failed) {
            if ([self.delegate respondsToSelector:@selector(onNewSessionFailure:)]) {
                [self.delegate onNewSessionFailure:response];
            }
        }
    }
}

- (void)newSessionForAppName:(NSString *)appName withHeader:(M1XRequestHeader *)header
{
    M1XRequestor *requestor = self.systemServiceRequestor;
    requestor.request = [[M1XRequest alloc] init];
    requestor.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@",self.systemURL,M1xSystemService,M1xSystemService_newSession]];
    requestor.request.header = header;
    requestor.request.body = [NSDictionary dictionaryWithObject:appName forKey:M1XSystemService_NewSession_body_appName];
    [requestor send];
}

- (void)fetchServiceConnectionDetails:(NSString *)appName withHeader:(M1XRequestHeader *)header
{
    M1XRequestor *requestor = self.systemServiceRequestor;
    requestor.request = [[M1XRequest alloc] init];
    requestor.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@",self.systemURL,M1xSystemService,M1xSystemService_fetchServiceConnectionDetails]];
    requestor.request.header = header;
    requestor.request.body = [NSDictionary dictionaryWithObject:appName forKey:M1XSystemService_NewSession_body_appName];
    [requestor send];
}

- (void)fetchContracts:(NSString *)appName withHeader:(M1XRequestHeader *)header
{
    M1XRequestor *requestor = self.systemServiceRequestor;
    requestor.request = [[M1XRequest alloc] init];
    requestor.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@",self.systemURL,M1xSystemService,M1xSystemService_fetchServiceConnectionDetails]];
    requestor.request.header = header;
    requestor.request.body = [NSDictionary dictionaryWithObject:appName forKey:M1XSystemService_NewSession_body_appName];
    [requestor send];
}


+(M1XRequestHeader*)GetSessionHeader
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    M1XRequestHeader *header = [[M1XRequestHeader alloc] init];
    header.userId = [userDefaults objectForKey:M1XRequestHeader_userID];
    header.password = [userDefaults objectForKey:M1XRequestHeader_password];
    header.domain = [userDefaults objectForKey:M1XRequestHeader_domain];
    header.role = [userDefaults objectForKey:M1XRequestHeader_domain];
    header.transactionId = [userDefaults objectForKey:M1XRequestHeader_transactionID];
    return header;
}

+(void)SaveSessionHeader:(M1XRequestHeader*)header
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:header.userId forKey:M1XRequestHeader_userID];
    [userDefaults setValue:header.password forKey:M1XRequestHeader_password];
    [userDefaults setValue:header.sessionEndDT forKey:M1XRequestHeader_sessionEndDT];
    [userDefaults setValue:header.domain forKey:M1XRequestHeader_domain];
    [userDefaults setValue:header.role forKey:M1XRequestHeader_role];
    [userDefaults setValue:header.transactionId forKey:M1XRequestHeader_transactionID];
    [userDefaults synchronize];
}

@end
