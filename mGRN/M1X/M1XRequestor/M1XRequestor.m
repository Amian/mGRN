//
//  M1XRequestor.m
//  mgrn
//
//  Created by Peter Barclay on 20/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//


#import "M1XRequestor.h"

@implementation M1XRequestor {
    NSMutableData *m1xResponseData;
    BOOL waitingForResponse;
    int responseStatusCode;
}

#define M1XRequestorResponse_INVALID 0
#define M1XRequestorResponse_VALID 1

@synthesize delegate = _delegate;
@synthesize request = _request;
@synthesize url = _url;
@synthesize response = _response;

- (id)initWithDelegate:(id)delegate
{
    if (self = [super init]) {
        self.request = [[M1XRequest alloc] init];
        self.delegate = delegate;
    } else {
        self = nil;
    }
    return self;
}

- (id)init
{
    return [self initWithDelegate:nil];
}

- (void)send
{
    if (![self connectedToInternet])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Exception"
                                                        message:@"Communication has failed. Please check your internet connection and try again. If this continues to happen, contact support."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        if ([self.delegate respondsToSelector:@selector(onM1XResponse:forRequest:)]) {
            [self.delegate onConnectionFailure];
        }
        return;
    }
    
    if (!waitingForResponse) {
        waitingForResponse = YES;
        [self clearResponse];
        
        m1xResponseData = [NSMutableData data];
        
        NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc] initWithURL:self.url];
        
        NSString *requestPostDataString = [self.request jsonValue];
        NSString *postLength =  [NSString stringWithFormat:@"%d", [requestPostDataString length]];
        [theRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [theRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [theRequest addValue:postLength forHTTPHeaderField:@"Content-Length"];
        [theRequest setHTTPMethod:@"POST"];
        [theRequest setHTTPBody:[requestPostDataString dataUsingEncoding:NSUTF8StringEncoding]];
//        NSLog(@"post data: %@", requestPostDataString);
        NSURLConnection *reqConn = [NSURLConnection connectionWithRequest:theRequest delegate:self];
        
        [reqConn start];
    } else {
// TODO: use delegate to inform about this kind of thing
        NSLog(@"Already waiting for response!");
    }
}

+ (M1XResponse*)sendSyncronousRequest:(M1XRequest*)newRequest withURL:(NSURL*)newURL
{
        NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc] initWithURL:newURL];
        
        NSString *requestPostDataString = [newRequest jsonValue];
        NSString *postLength =  [NSString stringWithFormat:@"%d", [requestPostDataString length]];
        [theRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [theRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [theRequest addValue:postLength forHTTPHeaderField:@"Content-Length"];
        [theRequest setHTTPMethod:@"POST"];
        [theRequest setHTTPBody:[requestPostDataString dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSURLResponse* response;
        NSError* error = nil;
        
        //Capturing server response
        NSData* result = [NSURLConnection sendSynchronousRequest:theRequest  returningResponse:&response error:&error];
//        NSString *resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    M1XResponse *theResponse = [[M1XResponse alloc] initWithResponseData:result];
        return theResponse;
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    waitingForResponse = NO;
//    NSLog(@"RESPONSE FAILURE: %@", self.response);
    if ([self.delegate respondsToSelector:@selector(onM1XResponse:forRequest:)]) {
        [self.delegate onM1XResponse:self.response forRequest:self.request];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        responseStatusCode = [(NSHTTPURLResponse *)response statusCode];
    } else {
        responseStatusCode = 0;
    }
    [m1xResponseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [m1xResponseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    waitingForResponse = NO;
    NSLog(@"RESPONSE DATA: %@", [[NSString alloc] initWithData:m1xResponseData encoding:NSUTF8StringEncoding]);
    self.response = [[M1XResponse alloc] initWithResponseData:m1xResponseData andStatusCode:responseStatusCode];
    if ([self.delegate respondsToSelector:@selector(onM1XResponse:forRequest:)]) {
        [self.delegate onM1XResponse:self.response forRequest:self.request];
    }
}

- (void)clearResponse
{
    self.response = nil;
}

-(BOOL)connectedToInternet
{
    NSURL *url=[NSURL URLWithString:@"http://www.google.com"];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"HEAD"];
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: NULL];
    
    return ([response statusCode]==200)?YES:NO;
}

@end
