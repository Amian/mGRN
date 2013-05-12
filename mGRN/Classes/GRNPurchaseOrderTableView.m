//
//  GRNPurchaseOrderTableView.m
//  mGRN
//
//  Created by Anum on 24/04/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "GRNPurchaseOrderTableView.h"
#import "PurchaseOrder+Management.h"

@interface GRNPurchaseOrderTableView()
@end

@implementation GRNPurchaseOrderTableView
@synthesize contract = _contract;

-(UIView*)cellContentViewWithFrame:(CGRect)frame purchaseOrder:(PurchaseOrder*)order indexPath:(NSIndexPath*)indexPath
{
    UIView *contentView = [[UIView alloc] initWithFrame:frame];
    contentView.backgroundColor = [UIColor clearColor];
    
    NSArray *valueArray = [NSArray array];
    NSArray *labelArray = [NSArray array];
    if (self.state == TableStateSelected && indexPath.section == self.selectedIndex.section)
    {
        
        valueArray = [NSArray arrayWithObjects:order.contract.name,order.contract.number,order.orderNumber,order.orderDescription,order.orderName, nil];
        labelArray = [NSArray arrayWithObjects:@"Contract Number:",@"Contract Name:",@"PO:",@"Description:",@"Supplier", nil];
    }
    else
    {
        
        valueArray = [NSArray arrayWithObjects:order.orderNumber,order.orderDescription,order.orderName,order.attention, nil];
        labelArray = [NSArray arrayWithObjects:@"PO:",@"Description:",@"Supplier:",@"Attention:", nil];
        
    }
    CGFloat y = 15.0;
    for (NSString* text in labelArray)
    {
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(15.0, y, 107.0, 18.0);
        label.text = text;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:13.0];
        [contentView addSubview:label];
        
        UILabel *label2 = [[UILabel alloc] init];
        label2.frame = CGRectMake(130.0, y, 210.0, 18.0);
        label2.text = [valueArray objectAtIndex:[labelArray indexOfObject:text]];
        label2.backgroundColor = [UIColor clearColor];
        label2.textColor = [UIColor whiteColor];
        label2.font = [UIFont boldSystemFontOfSize:14.0];
        [label2 sizeToFit];
        [contentView addSubview:label2];
        
        y += 25.0;
        
        if ([text hasPrefix:@"Attention"])
        {
            CALayer *bottomBorder = [CALayer layer];
            bottomBorder.frame = CGRectMake(130.0, y, label2.frame.size.width, 2.0f);
            bottomBorder.backgroundColor = [UIColor whiteColor].CGColor;
            [contentView.layer addSublayer:bottomBorder];
        }
        
    }
    
    return contentView;
}

#pragma mark - Table Data Source

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    cell.indentationLevel = 1;
    [cell.contentView addSubview:[self cellContentViewWithFrame:cell.contentView.frame purchaseOrder:[self.dataArray objectAtIndex:indexPath.section] indexPath:indexPath]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(NSArray*)getDataArray
{
    self.state = TableStateNormal;
    NSArray *array = [PurchaseOrder fetchPurchaseOrdersForContractNumber:self.contract.number
                                                                   inMOC:[CoreDataManager sharedInstance].managedObjectContext];
//    [self.myDelegate tableDidEndLoadingData:self];
    return array;
}


-(void)setContract:(Contract *)contract
{
    if (![_contract.number isEqualToString:contract.number])
    {
        _contract = contract;
        self.dataArray = [self getDataArray];
        if (!self.dataArray.count && contract.number)
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
    [self.service GetPurchaseOrdersWithHeader:[GRNM1XHeader GetHeader]
                               contractNumber:self.contract.number
                                          kco:self.kco
                             includeLineItems:NO];
}

-(void)onGetContractsSuccess:(NSDictionary *)orderData
{
    NSLog(@"response = %@",orderData);
    NSManagedObjectContext *context = [[CoreDataManager sharedInstance] managedObjectContext];
    NSError *error = NULL;
    NSArray *orders = [orderData objectForKey:@"purchaseOrders"];
    for (NSDictionary *dict in orders)
    {
        [PurchaseOrder insertPurchaseOrderWithData:dict
                                       forContract:self.contract
                            inManagedObjectContext:context
                                             error:&error];
    }
    self.dataArray = [self getDataArray];
    [self reloadData];
    [self.myDelegate tableDidEndLoadingData:self];
}

@end
