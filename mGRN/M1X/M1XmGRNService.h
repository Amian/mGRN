//
//  M1XContracts.h
//  mGRN
//
//  Created by Anum on 01/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M1XRequestor.h"

typedef enum
{
    RequestTypeNone,
    RequestTypeGetContracts,
    RequestTypeGetPurchaseOrdersByContracts,
    RequestTypeGetPurchaseOrdersDetails,
    RequestTypeGetWBSByContract,
    RequestTypeRejectionReason,
    RequestTypeDoSubmission
}
RequestType;

@interface M1XGRN : NSObject
@property (nonatomic, strong) NSString *deliveryDate;
@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *kco;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic, strong) NSString *orderNumber;
@property (nonatomic, strong) NSString *photo1;
@property (nonatomic, strong) NSString *photo2;
@property (nonatomic, strong) NSString *photo3;
@property (nonatomic, strong) NSString *signature;
@property (nonatomic, strong) NSString *supplierReference;
@end


@interface M1XLineItems : NSObject
@property (nonatomic, strong) NSString *exception;
@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *item;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic, strong) NSString *quantityDelivered;
@property (nonatomic, strong) NSString *quantityRejected;
@property (nonatomic, strong) NSString *serialNumber;
@property (nonatomic, strong) NSString *unitOfQuantityDelivered;
@property (nonatomic, strong) NSString *wbsCode;
@end


@protocol M1XmGRNDelegate <NSObject>

@optional

- (void)onAPIRequestSuccess:(NSDictionary *)response requestType:(RequestType)requestType;
- (void)onAPIRequestFailure:(M1XResponse *)response;

@end

@interface M1XmGRNService : NSObject<M1XRequestorDelegate>
@property (strong, nonatomic) id <M1XmGRNDelegate> delegate;
@property (strong, nonatomic) NSString *systemURL;

- (void)GetContractsWithHeader:(M1XRequestHeader *)header
                           kco:(NSString*)kco
                    includeWBS:(BOOL)includeWBS;

- (void)GetPurchaseOrdersWithHeader:(M1XRequestHeader *)header
                     contractNumber:(NSString*)contractnumber
                                kco:(NSString*)kco
                   includeLineItems:(BOOL)includeLineItems;

-(void)GetWBSWithHeader:(M1XRequestHeader*)header
         contractNumber:(NSString*)contractnumber
                    kco:(NSString*)kco;

-(void)DoSubmissionWithHeader:(M1XRequestHeader*)header
                          grn:(M1XGRN*)grn
                    lineItems:(NSArray*)lineItems
                          kco:(NSString*)kco;

- (void)GetPurchaseOrdersDetailsWithHeader:(M1XRequestHeader *)header
                            contractNumber:(NSString*)contractnumber
                                       kco:(NSString*)kco
                       purchaseOrderNumber:(NSString*)poNumber;

-(M1XResponse*)DoSubmissionSyncWithHeader:(M1XRequestHeader*)header grn:(M1XGRN*)grn lineItems:(NSArray*)lineItems kco:(NSString*)kco;


- (M1XResponse*)SynchronousGetPurchaseOrdersDetailsWithHeader:(M1XRequestHeader *)header contractNumber:(NSString*)contractnumber kco:(NSString*)kco purchaseOrderNumber:(NSString*)poNumber;

- (M1XResponse*)SynchronousGetPurchaseOrdersWithHeader:(M1XRequestHeader *)header contractNumber:(NSString*)contractnumber kco:(NSString*)kco includeLineItems:(BOOL)includeLineItems;

- (M1XResponse*)SynchronousGetContractsWithHeader:(M1XRequestHeader *)header kco:(NSString*)kco includeWBS:(BOOL)includeWBS;

-(void)GetRejectionReasonsWithHeader:(M1XRequestHeader*)header kco:(NSString*)kco;

@end
