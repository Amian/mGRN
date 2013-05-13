//
//  GRNOrderItemsTableView.m
//  mGRN
//
//  Created by Anum on 25/04/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNOrderItemsTableView.h"
#import "PurchaseOrderItem+Management.h"

@implementation GRNOrderItemsTableView
@synthesize purchaseOrder = _purchaseOrder;

#pragma mark - Table Data Source

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    cell.indentationLevel = 1;
    cell.textLabel.textColor = [UIColor whiteColor];
    if (indexPath.row == 0)
    {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
        cell.textLabel.text = @"Order Items";
    }
    else
    {
        PurchaseOrderItem *item = [self.dataArray objectAtIndex:indexPath.row -1];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.textLabel.text = [NSString stringWithFormat:@"%@: %@ [%i %@]",item.itemNumber, item.itemDescription, [item.quantityBalance intValue],item.uoq];
    }
    return cell;
}

-(NSArray*)getDataArray
{
    NSArray *array = [PurchaseOrderItem fetchPurchaseOrdersItemsForOrderNumber:self.purchaseOrder.orderNumber
                                                                         inMOC:[CoreDataManager sharedInstance].managedObjectContext];
//    [self.myDelegate tableDidEndLoadingData:self];
    return array;
}

-(void)setPurchaseOrder:(PurchaseOrder *)purchaseOrder
{
    if (![_purchaseOrder.orderNumber isEqualToString:purchaseOrder.orderNumber])
    {
        _purchaseOrder = purchaseOrder;
        self.dataArray = [self getDataArray];
        if (!self.dataArray.count && purchaseOrder.orderNumber)
        {
            [self getDataFromAPI];
        }
        else
        {
            [self reloadData];
            [self.myDelegate tableDidEndLoadingData:self];
        }
    }
    else
    {
        [self.myDelegate tableDidEndLoadingData:self];
    }
}

-(void)getDataFromAPI
{
    [super getDataFromAPI];
    [self.service GetPurchaseOrdersDetailsWithHeader:[GRNM1XHeader GetHeader]
                                      contractNumber:self.purchaseOrder.contract.number
                                                 kco:self.kco
                                 purchaseOrderNumber:self.purchaseOrder.orderNumber];
}

-(void)onAPIRequestSuccess:(NSDictionary *)orderData
{
    NSLog(@"response = %@",orderData);
    NSManagedObjectContext *context = [[CoreDataManager sharedInstance] managedObjectContext];
    NSError *error = NULL;
    NSArray *items = [[orderData objectForKey:@"purchaseOrder"] objectForKey:@"lineItems"];
    for (NSDictionary *dict in items)
    {
        [PurchaseOrderItem insertPurchaseOrderItemWithData:dict
                                          forPurchaseOrder:self.purchaseOrder
                                    inManagedObjectContext:context
                                                     error:&error];
    }
    self.dataArray = [self getDataArray];
    [self reloadData];
    [self.myDelegate tableDidEndLoadingData:self];
}

-(int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count + 1;
}

-(id)selectedObject
{
    @try
    {
        return [self.dataArray objectAtIndex:self.indexPathForSelectedRow.row - 1];
    }
    @catch (NSException *ex)
    {
        return nil;
    }
}

-(void)reloadData
{
    [super reloadData];
    if (self.dataArray.count > 0)
    {
        //Select first row
        [self selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]
                          animated:NO
                    scrollPosition:NO];
    }
}


-(void)searchForString:(NSString*)searchString
{
    if (searchString.length)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemNumber CONTAINS[c] %@ OR itemDescription CONTAINS[c] %@ OR  uoq CONTAINS[c] %@",searchString,searchString, searchString];
        self.dataArray = [[self getDataArray] filteredArrayUsingPredicate:predicate];
    }
    else
    {
        self.dataArray = [self getDataArray];
    }
    [self reloadData];
}

@end
