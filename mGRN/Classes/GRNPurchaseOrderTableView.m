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
@synthesize contract = _contract, errorLabel;


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 80.0)];
        self.errorLabel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/20);
        self.errorLabel.numberOfLines = 0;
        self.errorLabel.backgroundColor = [UIColor clearColor];
        self.errorLabel.textColor = [UIColor lightGrayColor];
        self.errorLabel.text = @"There are no purchase orders available for this contract.";
        [self addSubview:self.errorLabel];
        self.errorLabel.hidden = YES;
    }
    return self;
}

-(UIView*)cellContentViewWithFrame:(CGRect)frame purchaseOrder:(PurchaseOrder*)order indexPath:(NSIndexPath*)indexPath
{
    UIView *contentView = [[UIView alloc] initWithFrame:frame];
    contentView.backgroundColor = [UIColor clearColor];
    CGFloat x = 0.0;
    
    NSArray *valueArray = NULL;
    NSArray *labelArray = NULL;
    if (self.state == TableStateSelected && indexPath.section == self.selectedIndex.section)
    {
        
        valueArray = [NSArray arrayWithObjects:order.contract.name,order.contract.number,order.orderNumber,order.orderDescription,order.orderName, nil];
        labelArray = [NSArray arrayWithObjects:@"Contract Number:",@"Contract Name:",@"PO:",@"Description:",@"Supplier", nil];
        x = 130.0;
    }
    else
    {
        
        valueArray = [NSArray arrayWithObjects:order.orderNumber,order.orderDescription,order.orderName,order.attention, nil];
        labelArray = [NSArray arrayWithObjects:@"PO:",@"Description:",@"Supplier:",@"Attention:", nil];
        x = 90.0;
    }
    CGFloat y = 15.0;
    for (NSString* text in labelArray)
    {
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(15.0, y, 107.0, 35.0);
        label.text = text;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:13.0];
        [contentView addSubview:label];
        
        UILabel *label2 = [[UILabel alloc] init];
        label2.text = [valueArray objectAtIndex:[labelArray indexOfObject:text]];
        label2.backgroundColor = [UIColor clearColor];
        label2.textColor = [UIColor whiteColor];
        label2.font = [UIFont boldSystemFontOfSize:16.0];
        label2.minimumFontSize = 10.0;
        label2.numberOfLines = 2;
        label2.minimumScaleFactor = 0.5f;
        
        if ([text hasPrefix:@"Attention"])
        {
            [label2 sizeToFit];
            CALayer *bottomBorder = [CALayer layer];
            bottomBorder.frame = CGRectMake(x, y + 30, label2.frame.size.width, 2.0f);
            bottomBorder.backgroundColor = [UIColor whiteColor].CGColor;
            [contentView.layer addSublayer:bottomBorder];
        }
        
        label2.frame = CGRectMake(x, y, 200.0 + ( x > 100? 0 : 40.0), 40.0);
        [contentView addSubview:label2];
        
        y += 35.0;
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
                                                                   inMOC:[CoreDataManager moc]];
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
    [self.service GetPurchaseOrdersWithHeader:[GRNM1XHeader Header]
                               contractNumber:self.contract.number
                                          kco:self.kco
                             includeLineItems:NO];
}

-(void)onAPIRequestSuccess:(NSDictionary *)orderData requestType:(RequestType)requestType
{
//    NSLog(@"response = %@",orderData);
    NSManagedObjectContext *context = [CoreDataManager moc];
    NSError *error = NULL;
    NSArray *orders = [orderData objectForKey:@"purchaseOrders"];
    for (NSDictionary *dict in orders)
    {
        [PurchaseOrder insertPurchaseOrderWithData:dict
                                       forContract:self.contract
                            inManagedObjectContext:context
                                             error:&error];
    }
    [context save:nil];
    self.dataArray = [self getDataArray];
    [self reloadData];
    [self.myDelegate tableDidEndLoadingData:self];
}

-(void)onAPIRequestFailure:(M1XResponse *)response
{
    [self.myDelegate failedToGetData:self];
}

-(void)searchForString:(NSString*)searchString
{
    if (searchString.length)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"orderNumber CONTAINS[c] %@ OR orderDescription CONTAINS[c] %@ OR  orderName CONTAINS[c] %@ OR attention CONTAINS[c] %@",searchString,searchString, searchString, searchString];
        self.dataArray = [[self getDataArray] filteredArrayUsingPredicate:predicate];
    }
    else
    {
        self.dataArray = [self getDataArray];
    }
    [self reloadData];
}
@end
