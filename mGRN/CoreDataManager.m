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
#import "RejectionReasons+Management.h"
#import "SDN+Management.h"
#import "GRN+Management.h"
#import "GRNAppDelegate.h"

#define DefaultSubmissionTimeInterval 5.0;

@interface CoreDataManager() <M1XmGRNDelegate>
@property float timeInterval;
@property (nonatomic, strong) NSOperationQueue *submissionQueue;
@property BOOL dataIsBeingRemoved;
@end

@implementation CoreDataManager
@synthesize managedObjectContext,
timeInterval = _timeInterval,
submissionQueue = _submissionQueue,
dataIsBeingRemoved = _dataIsBeingRemoved;

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
        self.timeInterval = DefaultSubmissionTimeInterval;
        self.dataIsBeingRemoved = NO;
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


+(void)removeData:(BOOL)allData
{
    [[CoreDataManager sharedInstance] setDataIsBeingRemoved:YES];
    NSManagedObjectContext *context = [CoreDataManager moc];
    [Contract removeAllContractsInManagedObjectContext:context];
    [PurchaseOrder removeAllPurchaseOrdersInManagedObjectContext:context];
    [PurchaseOrderItem removeAllPurchaseOrdersItemsInManagedObjectContext:context];
    [WBS removeAllWBSInManagedObjectContext:context];
    [RejectionReasons removeAllRejectionReasonsInMOC:context];
    if (allData)
    {
        [SDN removeAllSDNsinMOC:context];
        [GRN removeAllObjectsInManagedObjectContext:context];
    }
}

-(void)submitGRN
{
    NSLog(@"Submit GRN Called");
    NSArray *submittedGRN = [GRN fetchSubmittedGRNInMOC:[CoreDataManager NewManagedObjectContext]];
    if (submittedGRN.count)
    {
        if ([self connectedToInternet])
        {
            NSOperationQueue *myQueue = self.submissionQueue;
            [myQueue addOperationWithBlock:^{
                NSManagedObjectContext *context = [CoreDataManager NewManagedObjectContext];
                NSArray *allGRNs = [GRN fetchSubmittedGRNInMOC:context];
                for (GRN *grn in allGRNs)
                {
                    if (![self connectedToInternet]) break;
                    [self submit:grn];
                }
                if ([[GRN fetchSubmittedGRNInMOC:context] count])
                {
                    self.timeInterval = self.timeInterval *2;
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self performSelector:@selector(submitGRN)
                                   withObject:nil
                                   afterDelay:self.timeInterval];
                        NSLog(@"Repeat after time= %f",self.timeInterval);
                    }];
                }
                else
                {
                    self.timeInterval = DefaultSubmissionTimeInterval;
                }
            }];
        }
        else
        {
            self.timeInterval = self.timeInterval *2;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self performSelector:@selector(submitGRN)
                           withObject:nil
                           afterDelay:self.timeInterval];
                NSLog(@"Repeat after time= %f",self.timeInterval);
            }];
        }
    }
    else
    {
        self.timeInterval = DefaultSubmissionTimeInterval;
    }
}

- (BOOL)submit:(GRN*)newGRN
{
    M1XmGRNService *service = [[M1XmGRNService alloc] init];
    //    service.delegate = self;
    NSString *kco = [[NSUserDefaults standardUserDefaults] objectForKey:KeyKCO];
    @try
    {
        kco = [kco componentsSeparatedByString:@","].count > 0? [[kco componentsSeparatedByString:@","] objectAtIndex:0] : @"";
    }
    @catch (NSException *ex)
    {
        //
    }
    M1XGRN *grn = [[M1XGRN alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd'T'00:00:00";
    grn.deliveryDate = [formatter stringFromDate:newGRN.deliveryDate];
    
    grn.kco = kco;
    grn.notes = newGRN.notes;
    grn.orderNumber = newGRN.orderNumber;
    grn.photo1 = newGRN.photo1URI;
    grn.photo2 = newGRN.photo2URI;
    grn.photo3 = newGRN.photo3URI;
    grn.signature = newGRN.signatureURI;
    grn.supplierReference = newGRN.supplierReference;
    NSMutableArray *items = [NSMutableArray array];
    for (GRNItem *item in newGRN.lineItems)
    {
        M1XLineItems *newItem = [[M1XLineItems alloc] init];
        newItem.exception = item.exception.length? item.exception : @"0";
        newItem.item = item.itemNumber;
        newItem.notes = item.notes;
        newItem.quantityDelivered = [NSString stringWithFormat:@"%i",[item.quantityDelivered intValue]];
        newItem.quantityRejected = [NSString stringWithFormat:@"%i",[item.quantityRejected intValue]];
        newItem.serialNumber = item.serialNumber;
        newItem.unitOfQuantityDelivered = item.uoq;
        newItem.wbsCode = item.wbsCode;
        [items addObject:newItem];
    }
    
    M1XResponse *result = [service DoSubmissionSyncWithHeader:[GRNM1XHeader Header]
                                                          grn:grn
                                                    lineItems:items
                                                          kco:kco];
    if (result.header.success)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSManagedObjectContext *context = [CoreDataManager NewManagedObjectContext];
            [context deleteObject:[GRN fetchGRNWithSDN:newGRN.supplierReference inMOC:context]];
            [context save:nil];
        }];
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

-(void)getAllDataInBG
{
    
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    moc.parentContext = self.managedObjectContext;

    NSLog(@"main = %i, bg = %i",[PurchaseOrder poCountInMOC:self.managedObjectContext],[PurchaseOrder poCountInMOC:moc]);
    
    [moc performBlock:^{
        
        @try
        {
            NSLog(@"main = %i, bg = %i",[PurchaseOrder poCountInMOC:self.managedObjectContext],[PurchaseOrder poCountInMOC:moc]);

            self.dataIsBeingRemoved = NO;
            NSLog(@"Getting Data");
            NSManagedObjectContext *moc =  [CoreDataManager NewManagedObjectContext];

            //check if operation needs to be cancelled
            if (self.dataIsBeingRemoved) [NSException raise:@"Data is being removed" format:@""];

            NSArray *allContracts = [Contract fetchAllContractsInManagedObjectContext:moc];

            NSString *kco = [[NSUserDefaults standardUserDefaults] objectForKey:KeyKCO];
            kco = [kco componentsSeparatedByString:@","].count > 0? [[kco componentsSeparatedByString:@","] objectAtIndex:0] : @"";
            M1XmGRNService *service = [[M1XmGRNService alloc] init];

            for (Contract *contract in allContracts)
            {
                if (self.dataIsBeingRemoved) [NSException raise:@"Data is being removed" format:@""];
                if (!contract.purchaseOrders.count)
                {
                    //Get PO
                    M1XResponse *response = [service SynchronousGetPurchaseOrdersWithHeader:[GRNM1XHeader Header]
                                                                             contractNumber:contract.number
                                                                                        kco:kco
                                                                           includeLineItems:YES];
                    NSArray *poArray = [response.body objectForKey:@"purchaseOrders"];
                    for (NSDictionary *dict in poArray)
                    {
                        if (self.dataIsBeingRemoved) [NSException raise:@"Data is being removed" format:@""];
                        [PurchaseOrder insertPurchaseOrderWithData:dict
                                                       forContract:contract
                                            inManagedObjectContext:moc
                                                             error:nil];
                    }
//                    NSLog(@"Got PO for contract  = %@",contract.name);
                }
                else
                {
                    for (PurchaseOrder *po in contract.purchaseOrders)
                    {
                        if (self.dataIsBeingRemoved) [NSException raise:@"Data is being removed" format:@""];
                        if (!po.lineItems.count)
                        {
                            M1XResponse *response = [service SynchronousGetPurchaseOrdersDetailsWithHeader:[GRNM1XHeader Header]
                                                                                            contractNumber:contract.number
                                                                                                       kco:kco
                                                                                       purchaseOrderNumber:po.orderNumber];
                            NSArray *items = [[response.body objectForKey:@"purchaseOrder"] objectForKey:@"lineItems"];
                            for (NSDictionary *dict in items)
                            {
                                if (self.dataIsBeingRemoved) [NSException raise:@"Data is being removed" format:@""];
                                [PurchaseOrderItem insertPurchaseOrderItemWithData:dict
                                                                  forPurchaseOrder:po
                                                            inManagedObjectContext:moc
                                                                             error:nil];
//                                NSLog(@"Line items added for contract no = %@, name = %@",contract.number, contract.name);
                            }

                        }
                    }
                }
            }
//            NSLog(@"Finished getting all data from API");
        }
        @catch (NSException *ex)
        {
            //This happens if we attempt to remove all data while data is being fetched from API
            //Not an issue as after getting new data this method will be called again
//            NSLog(@"Could not get all data from API, ex = %@",ex);
            self.dataIsBeingRemoved = NO;
        }
        
        // push to parent
        NSError *error;
        if (![moc save:&error])
        {
            // handle error
        }
        
        // save parent to disk asynchronously
        [self.managedObjectContext performBlock:^{
            NSError *error;
            if (![self.managedObjectContext save:&error])
            {
                // handle error
            }
        }];
    }];
    

}

+(NSManagedObjectContext*)moc
{
    return [CoreDataManager sharedInstance].managedObjectContext;
}

+(NSManagedObjectContext*)NewManagedObjectContext
{
    GRNAppDelegate *delegate = (GRNAppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator: [delegate persistentStoreCoordinator]];
    return context;
}

-(NSOperationQueue*)submissionQueue
{
    if (!_submissionQueue)
    {
        _submissionQueue = [[NSOperationQueue alloc] init];
        [_submissionQueue setName:@"SubmissionQueue"];
    }
    return _submissionQueue;
}

@end
