//
//  M1XContracts.m
//  mGRN
//
//  Created by Anum on 01/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "M1XmGRNService.h"
#import <objc/runtime.h>

#define M1xMgrnService_GetContracts @"GetContracts"
#define M1xMgrnService_GetPurchaseOrdersByContract @"GetPurchaseOrdersByContract"
#define M1xMgrnService_GetPurchaseOrdersDetails @"GetPurchaseOrderDetails"
#define M1xMgrnService_GetWBSByContract @"GetWBSByContract"
#define M1xMgrnService_DoSubmission @"DoSubmission"
#define M1xMgrnService_GetRejectionReasons @"GetRejectionReasons"

@interface M1XmGRNService ()

@property (strong, nonatomic) M1XRequestor *systemServiceRequestor;
@property RequestType requestType;
@end

@implementation M1XGRN
@end


@implementation M1XLineItems
@end



@implementation M1XmGRNService
@synthesize delegate = _delegate, systemServiceRequestor = _systemServiceRequestor, systemURL = _systemURL, requestType = _requestType;

-(NSString *)systemURL
{
    if (!_systemURL) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _systemURL = [NSString stringWithFormat:@"https://%@:%@/%@",
                      [defaults objectForKey:KeyServiceServer],
                      [defaults objectForKey:KeyServicePort],
                      [defaults objectForKey:KeyServiceName]];
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
            if ([[response.header valueForKey:@"success"] boolValue]) {
                if ([self.delegate respondsToSelector:@selector(onAPIRequestSuccess:requestType:)]) {
                    [self.delegate onAPIRequestSuccess:response.body requestType:self.requestType];
                }
            } else {
                failed = YES;
            }
        } else {
            failed = YES;
        }
        if (failed) {
            if ([self.delegate respondsToSelector:@selector(onAPIRequestFailure:)]) {
                [self.delegate onAPIRequestFailure:response];
            }
        }
    }
}

-(void)onConnectionFailure
{
    if ([self.delegate respondsToSelector:@selector(onAPIRequestFailure:)])
        [self.delegate onAPIRequestFailure:nil];
}

- (void)GetContractsWithHeader:(M1XRequestHeader *)header kco:(NSString*)kco includeWBS:(BOOL)includeWBS
{
    M1XRequestor *requestor = self.systemServiceRequestor;
    requestor.request = [[M1XRequest alloc] init];
    requestor.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",self.systemURL,M1xMgrnService_GetContracts]];
    requestor.request.header = header;
    requestor.request.body = [NSDictionary dictionaryWithObjectsAndKeys:
                              includeWBS? @"true" : @"false",@"includeWBS",
                              kco,@"kco",
                              nil];
    M1XRequestorState state = [requestor send];
    if (state == M1XRequestorRequestSent)
    {
        
    }
//    NSLog(@"request = %@",requestor.request);
}

- (void)GetPurchaseOrdersWithHeader:(M1XRequestHeader *)header contractNumber:(NSString*)contractnumber kco:(NSString*)kco includeLineItems:(BOOL)includeLineItems
{
    M1XRequestor *requestor = self.systemServiceRequestor;
    requestor.request = [[M1XRequest alloc] init];
    requestor.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",self.systemURL,M1xMgrnService_GetPurchaseOrdersByContract]];
    requestor.request.header = header;
    requestor.request.body = [NSDictionary dictionaryWithObjectsAndKeys:
                              contractnumber,@"contractNumber",
                              includeLineItems? @"true" : @"false",@"includeLineItems",
                              kco,@"kco",
                              nil];
    [requestor send];
}

- (void)GetPurchaseOrdersDetailsWithHeader:(M1XRequestHeader *)header contractNumber:(NSString*)contractnumber kco:(NSString*)kco purchaseOrderNumber:(NSString*)poNumber
{
    M1XRequestor *requestor = self.systemServiceRequestor;
    requestor.request = [[M1XRequest alloc] init];
    requestor.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",self.systemURL,M1xMgrnService_GetPurchaseOrdersDetails]];
    requestor.request.header = header;
    requestor.request.body = [NSDictionary dictionaryWithObjectsAndKeys:
                              contractnumber,@"contractNumber",
                              kco,@"kco",
                              poNumber,@"purchaseOrderNumber",
                              nil];
    [requestor send];
}

-(void)GetWBSWithHeader:(M1XRequestHeader*)header contractNumber:(NSString*)contractnumber kco:(NSString*)kco
{
    M1XRequestor *requestor = self.systemServiceRequestor;
    requestor.request = [[M1XRequest alloc] init];
    requestor.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",self.systemURL,M1xMgrnService_GetWBSByContract]];
    requestor.request.header = header;
    requestor.request.body = [NSDictionary dictionaryWithObjectsAndKeys:
                              contractnumber,@"contractNumber",
                              kco,@"kco",
                              nil];
    [requestor send];
}


-(void)GetRejectionReasonsWithHeader:(M1XRequestHeader*)header kco:(NSString*)kco
{
    M1XRequestor *requestor = self.systemServiceRequestor;
    requestor.request = [[M1XRequest alloc] init];
    requestor.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",self.systemURL,M1xMgrnService_GetRejectionReasons]];
    requestor.request.header = header;
    requestor.request.body = [NSDictionary dictionaryWithObjectsAndKeys:
                              kco,@"kco",
                              nil];
    [requestor send];
}

-(void)DoSubmissionWithHeader:(M1XRequestHeader*)header grn:(M1XGRN*)grn lineItems:(NSArray*)lineItems kco:(NSString*)kco
{
    M1XRequestor *requestor = self.systemServiceRequestor;
    requestor.request = [[M1XRequest alloc] init];
    requestor.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",self.systemURL,M1xMgrnService_DoSubmission]];
    requestor.request.header = header;
    NSMutableDictionary *body = [[self getDictFromObject:grn] mutableCopy];
    NSMutableArray *items = [NSMutableArray array];
    for (M1XLineItems *item in lineItems)
    {
        [items addObject:[self getDictFromObject:item]];
    }
    [body setValue:items forKey:@"lineItems"];
    requestor.request.body = body;
    requestor.request.extraParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                         kco,@"kco",
                                         nil];
    [requestor send];
}

-(M1XResponse*)DoSubmissionSyncWithHeader:(M1XRequestHeader*)header grn:(M1XGRN*)grn lineItems:(NSArray*)lineItems kco:(NSString*)kco
{
    M1XRequest *request = [[M1XRequest alloc] init];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",self.systemURL,M1xMgrnService_DoSubmission]];
    request.header = header;
    NSMutableDictionary *body = [[self getDictFromObject:grn] mutableCopy];
    NSMutableArray *items = [NSMutableArray array];
    for (M1XLineItems *item in lineItems)
    {
        [items addObject:[self getDictFromObject:item]];
    }
    [body setValue:items forKey:@"lineItems"];
    request.body = body;
    request.extraParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                               kco,@"kco",
                               nil];
    M1XResponse *result = [M1XRequestor sendSyncronousRequest:request withURL:url];
//    NSLog(@"order number = %@",[body objectForKey:@"orderNumber"]);
    return result;
}

-(NSDictionary*)getDictFromObject:(id)object
{
    unsigned int propertyCount = 0;
    objc_property_t * properties = class_copyPropertyList([object class], &propertyCount);
    
    NSMutableArray * propertyNames = [NSMutableArray array];
    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);
        [propertyNames addObject:[NSString stringWithUTF8String:name]];
    }
    free(properties);
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSString *key in propertyNames)
    {
        if ([key isEqualToString:@"ID"])
        {
            @try {
                [dict setValue:[object valueForKey:key] forKey:@"id"];
            }
            @catch (NSException *e)
            {
                NSLog(@"exception: key = %@",key);
            }
        }
        else
        {
            @try {
                [dict setValue:[object valueForKey:key] forKey:key];
            }
            @catch (NSException *e)
            {
                NSLog(@"exception: key = %@",key);
            }
        }
    }
    return dict;
}

#pragma mark - Syncronous requests

- (M1XResponse*)SynchronousGetContractsWithHeader:(M1XRequestHeader *)header kco:(NSString*)kco includeWBS:(BOOL)includeWBS
{
    M1XRequest *request = [[M1XRequest alloc] init];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",self.systemURL,M1xMgrnService_GetContracts]];
    request.header = header;
    request.body = [NSDictionary dictionaryWithObjectsAndKeys:
                    includeWBS? @"true" : @"false",@"includeWBS",
                    kco,@"kco",
                    nil];
    return [M1XRequestor sendSyncronousRequest:request withURL:url];
}

- (M1XResponse*)SynchronousGetPurchaseOrdersWithHeader:(M1XRequestHeader *)header contractNumber:(NSString*)contractnumber kco:(NSString*)kco includeLineItems:(BOOL)includeLineItems
{
    M1XRequest *request = [[M1XRequest alloc] init];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",self.systemURL,M1xMgrnService_GetPurchaseOrdersByContract]];
    request.header = header;
    request.body = [NSDictionary dictionaryWithObjectsAndKeys:
                    contractnumber,@"contractNumber",
                    includeLineItems? @"true" : @"false",@"includeLineItems",
                    kco,@"kco",
                    nil];
    return [M1XRequestor sendSyncronousRequest:request withURL:url];
}

- (M1XResponse*)SynchronousGetPurchaseOrdersDetailsWithHeader:(M1XRequestHeader *)header contractNumber:(NSString*)contractnumber kco:(NSString*)kco purchaseOrderNumber:(NSString*)poNumber
{
    M1XRequest *request = [[M1XRequest alloc] init];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",self.systemURL,M1xMgrnService_GetPurchaseOrdersDetails]];
    request.header = header;
    request.body = [NSDictionary dictionaryWithObjectsAndKeys:
                    contractnumber,@"contractNumber",
                    kco,@"kco",
                    poNumber,@"purchaseOrderNumber",
                    nil];
    return [M1XRequestor sendSyncronousRequest:request withURL:url];
}

@end
