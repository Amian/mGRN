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
@synthesize purchaseOrder = _purchaseOrder, grnItems = _grnItems;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.delegate = self;
        self.grnItems = NULL;
    }
    return self;
}

#pragma mark - Table Data Source

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    cell.indentationLevel = 1;
    cell.textLabel.textColor = [UIColor whiteColor];
    
    PurchaseOrderItem *item = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:20.0];
    if (self.grnItems.count)
    {
        GRNItem *grnItem = [self getGRNItemForPOItem:item];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMinimumFractionDigits:2];
        [formatter setMaximumFractionDigits:2];
        [formatter setRoundingMode:NSNumberFormatterRoundDown];
        
        //        float realValue = [grnItem.quantityDelivered floatValue];
        //            float formattedValue = [[formatter stringFromNumber:grnItem.quantityDelivered] floatValue];
        //        NSString *delivered = realValue > formattedValue? [NSString stringWithFormat:@"%g",realValue] : [NSString stringWithFormat:@"%.02f",formattedValue];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@: %@ [%.02f of %.02f %@]",item.itemNumber, item.itemDescription, [grnItem.quantityDelivered doubleValue] ,[item.quantityBalance doubleValue],item.uoq];
    }
    else
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%@: %@ [%.02f %@]",item.itemNumber, item.itemDescription ,[item.quantityBalance floatValue],item.uoq];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    return cell;
    
}

-(GRNItem*)getGRNItemForPOItem:(PurchaseOrderItem*)item
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemNumber = %@", item.itemNumber];
    return [[self.grnItems filteredArrayUsingPredicate:predicate] lastObject];
}

-(NSArray*)getDataArray
{
    return [[self.purchaseOrder.lineItems allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"itemNumber" ascending:YES]]];
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
    [self.service GetPurchaseOrdersDetailsWithHeader:[GRNM1XHeader Header]
                                      contractNumber:self.purchaseOrder.contract.number
                                                 kco:self.kco
                                 purchaseOrderNumber:self.purchaseOrder.orderNumber];
}

-(void)onAPIRequestSuccess:(NSDictionary *)orderData requestType:(RequestType)requestType
{
    NSLog(@"response = %@",orderData);
    NSManagedObjectContext *context = [CoreDataManager moc];
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
    return self.dataArray.count;
}

-(id)selectedObject
{
    @try
    {
        return [self.dataArray objectAtIndex:self.indexPathForSelectedRow.row];
    }
    @catch (NSException *ex)
    {
        return nil;
    }
}

-(void)reloadData
{
    [super reloadData];
//    self.allowsSelection = self.dataArray.count > 1? YES : NO;
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

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//
//    // Create label with section title
//    UILabel *label = [[UILabel alloc] init] ;
//    label.frame = CGRectMake(0, 0, self.frame.size.width, 50);
//    label.backgroundColor = [UIColor colorWithWhite:0.05 alpha:1];
//    label.textColor = [UIColor whiteColor];
//    label.shadowOffset = CGSizeMake(0.0, 1.0);
//    label.font = [UIFont boldSystemFontOfSize:20.0];
//    label.text = @"     Order Items";
//
//    // Create header view and add label as a subview
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 140, 30)];
//    [view addSubview:label];
//
//    return view;
//}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 50.0;
//}
@end
