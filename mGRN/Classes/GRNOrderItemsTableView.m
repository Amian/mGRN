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
    NSString *MyIdentifier = [NSString stringWithFormat:@"MyIdentifier %i", indexPath.row];
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil || self.reloading)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
        //TODO: Get data from API
        cell.indentationLevel = 1;
        
        //        if (indexPath.row != 0 && [self indexPathForSelectedRow].row == indexPath.row)
        //        {
        cell.textLabel.textColor = [UIColor whiteColor];
        //            cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
        //        }
        //        else
        //        {
        //            cell.textLabel.textColor = [UIColor lightGrayColor];
        //        }
        //
        
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
    }
    if (indexPath.section == self.dataArray.count - 1)
        self.reloading = NO;
    return cell;
}

-(NSArray*)getDataArray
{
    NSArray *array = [PurchaseOrderItem fetchPurchaseOrdersItemsForOrderNumber:self.purchaseOrder.orderNumber
                                                               inMOC:[CoreDataManager sharedInstance].managedObjectContext];
    [self.myDelegate tableDidEndLoadingData:self];
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
        }
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

-(void)onGetContractsSuccess:(NSDictionary *)orderData
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

@end
