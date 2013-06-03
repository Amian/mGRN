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

typedef enum
{
    RequestStateNone,
    RequestStateSession,
    RequestStateService
}
RequestState;



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

@implementation M1XServiceConnection
@synthesize port,server,serviceName;
@end

// ------------------------------------------

@interface M1X ()
@property RequestState requestState;
@property (strong, nonatomic) M1XRequestor *systemServiceRequestor;

@end

@implementation M1X

@synthesize systemURL = _systemURL;
@synthesize systemServiceRequestor = _systemServiceRequestor;
@synthesize requestState;

-(NSString *)systemURL
{
    if (!_systemURL) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _systemURL = [defaults objectForKey:KeySystemURI];
//        if (!_systemURL || !_systemURL.length)
//        {
//            _systemURL = DefaultSystemURI;
//        }
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
    M1xException ex = M1xExceptionNone;
    if (self.delegate) {
        if (response.header.success) {
            switch (self.requestState)
            {
                case RequestStateService:
                {
                    M1XServiceConnection *sConn = [[M1XServiceConnection alloc] init];
                    NSDictionary *serviceDict = [[response.body objectForKey:@"serviceConnectionDetails"] lastObject];
                    sConn.port = [serviceDict objectForKey:@"port"];
                    sConn.server = [serviceDict objectForKey:@"server"];
                    sConn.serviceName = [serviceDict objectForKey:@"serviceName"];
                    if ([self.delegate respondsToSelector:@selector(onServiceConnectionSuccess:)])
                        [self.delegate onServiceConnectionSuccess:sConn];
                    break;
                }
                case RequestStateSession:
                    if ([[response.body valueForKey:@"userAuthenticated"] boolValue])
                    {
                        if ([self.delegate respondsToSelector:@selector(onNewSessionSuccess:)])
                        {
                            M1XSession *session = [[M1XSession alloc] init];
                            session.domain = request.header.domain;
                            //session.password = [response.body valueForKey:@"password"];
                            session.sessionKey = [response.body valueForKey:@"passKey"];
                            session.sessionEndDT = [response.body valueForKey:@"sessionEndDT"];
                            session.userId = request.header.userId;
                            session.kco = [response.body valueForKey:@"kco"];
                            [self.delegate onNewSessionSuccess:session];
                        }
                    }
                    else
                    {
                        ex = M1xExceptionAuthenticationFailed;
                        failed = YES;
                    }
                    break;
                case RequestStateNone:
                    break;
            }
        }
        else
        {
            ex = M1xExceptionNoSuccess;
            failed = YES;
        }
    }
    if (failed) {
        if ([self.delegate respondsToSelector:@selector(onNewSessionFailure:exceptionType:)]) {
            [self.delegate onNewSessionFailure:response exceptionType:ex];
        }
    }
}

-(void)onConnectionFailure
{
    if ([self.delegate respondsToSelector:@selector(onNewSessionFailure:exceptionType:)])
        [self.delegate onNewSessionFailure:nil exceptionType:M1xExceptionNoInternetConnection];
}

- (void)newSessionForAppName:(NSString *)appName withHeader:(M1XRequestHeader *)header
{
    M1XRequestor *requestor = self.systemServiceRequestor;
    requestor.request = [[M1XRequest alloc] init];
    requestor.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@",self.systemURL,M1xSystemService,M1xSystemService_newSession]];
    requestor.request.header = header;
    requestor.request.body = [NSDictionary dictionaryWithObject:appName forKey:M1XSystemService_NewSession_body_appName];
    [requestor send];
    self.requestState = RequestStateSession;
    NSLog(@"request = %@",requestor.request);
    
}

- (void)FetchServiceConnectionDetailsForAppName:(NSString *)appName withHeader:(M1XRequestHeader *)header
{
    M1XRequestor *requestor = self.systemServiceRequestor;
    requestor.request = [[M1XRequest alloc] init];
    requestor.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@",self.systemURL,M1xSystemService,M1xSystemService_fetchServiceConnectionDetails]];
    requestor.request.header = header;
    requestor.request.body = [NSDictionary dictionaryWithObject:appName forKey:M1XSystemService_NewSession_body_appName];
    [requestor send];
    self.requestState = RequestStateService;
    NSLog(@"request = %@",requestor.request);
}

@end
