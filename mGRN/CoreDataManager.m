//
//  CoreDataManager.m
//  mGRN
//
//  Created by Anum on 01/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "CoreDataManager.h"
#import "GRN+Management.h"
#import "GRNItem+Management.h"
#import "GRNM1XHeader.h"

@interface CoreDataManager()
@property (nonatomic, strong) GRN *grn;
@property float timeInterval;
@end

@implementation CoreDataManager
@synthesize managedObjectContext, grn = _grn, processing = _processing, timeInterval = _timeInterval;
static CoreDataManager *sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (CoreDataManager *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.timeInterval = 2.0 * 60.0;
    }
    
    return self;
}

// We don't want to allocate a new instance, so return the current one.
+ (id)allocWithZone:(NSZone*)zone {
    return [self sharedInstance];
}

// Equally, we don't want to generate multiple copies of the singleton.
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

+(void)removeAllContracts
{
    NSManagedObjectContext *context = [CoreDataManager sharedInstance].managedObjectContext;
    [Contract removeAllContractsInManagedObjectContext:context];
    [PurchaseOrder removeAllPurchaseOrdersInManagedObjectContext:context];
    [PurchaseOrderItem removeAllPurchaseOrdersItemsInManagedObjectContext:context];
    [WBS removeAllWBSInManagedObjectContext:context];
}

-(void)submitGRN
{
    self.processing = NO;
    BOOL tryAgain = NO;
    if ([self connectedToInternet])
    {
        NSArray *submittedGRN = [GRN fetchSubmittedGRNInMOC:self.managedObjectContext];
        for (GRN *grn in submittedGRN)
        {
            BOOL result = [self submit:grn];
            tryAgain = tryAgain? YES : !result;
        }
    }
    else
    {
        tryAgain = YES;
    }
    if (tryAgain)
    {
        [self performSelector:@selector(submitGRN) withObject:nil afterDelay:self.timeInterval];
        self.timeInterval = self.timeInterval *2;
        //TODO: Try again in a bit
    }
    else
    {
        self.timeInterval = 2.0;
    }
}

- (BOOL)submit:(GRN*)newGRN
{
    self.grn = newGRN;
    [self.managedObjectContext save:nil];
    M1XmGRNService *service = [[M1XmGRNService alloc] init];
    //    service.delegate = self;
    NSString *kco = [[NSUserDefaults standardUserDefaults] objectForKey:KeyKCO];
    kco = [kco componentsSeparatedByString:@","].count > 0? [[kco componentsSeparatedByString:@","] objectAtIndex:0] : @"";
    
    M1XGRN *grn = [[M1XGRN alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd'T'00:00:00";
    grn.deliveryDate = [formatter stringFromDate:newGRN.deliveryDate];
    
    grn.kco = kco;
    grn.notes = newGRN.notes;
    grn.orderNumber = newGRN.purchaseOrder.orderNumber;
    grn.photo1 = newGRN.photo1URI;
    grn.photo2 = newGRN.photo2URI;
    grn.photo3 = newGRN.photo3URI;
    grn.signature = newGRN.signatureURI;
    grn.supplierReference = newGRN.supplierReference;
    NSMutableArray *items = [NSMutableArray array];
    for (GRNItem *item in newGRN.lineItems)
    {
        M1XLineItems *newItem = [[M1XLineItems alloc] init];
        newItem.exception = item.exception;
        newItem.item = item.itemNumber;
        newItem.notes = item.notes;
        newItem.quantityDelivered = [NSString stringWithFormat:@"%i",[item.quantityDelivered intValue]];
        newItem.quantityRejected = [NSString stringWithFormat:@"%i",[item.quantityRejected intValue]];
        newItem.serialNumber = item.serialNumber;
        newItem.unitOfQuantityDelivered = item.uoq;
        newItem.wbsCode = item.wbsCode;
        [items addObject:newItem];
    }
    
    M1XResponse *result = [service DoSubmissionSyncWithHeader:[GRNM1XHeader GetHeader]
                                                          grn:grn
                                                    lineItems:items
                                                          kco:kco];
    if (result.header.success)
    {
        //TODO: Add sdn
        [self.managedObjectContext deleteObject:self.grn];
        [self.managedObjectContext save:nil];
    }
    else
    {
        //TODO: Try again
    }
    return result.header.success;
}

- (BOOL)connectedToInternet
{
    NSURL *url=[NSURL URLWithString:@"http://www.google.com"];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"HEAD"];
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: NULL];
    
    return ([response statusCode]==200)?YES:NO;
}
@end
