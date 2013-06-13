//
//  GRNContractTableView.m
//  mGRN
//
//  Created by Anum on 24/04/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNContractTableView.h"
#import "Contract+Management.h"

@interface GRNContractTableView()
@end

@implementation GRNContractTableView

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.dataArray = [self getDataArray];
        if (!self.dataArray.count)
        {
            [self getDataFromAPI];
        }
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
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    Contract *contract = [self.dataArray objectAtIndex:indexPath.section];
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:20.0];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:18.0];
    
    cell.textLabel.text = contract.number;
    cell.detailTextLabel.text = contract.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(float)rowHeight
{
    return self.frame.size.height/8;
}

#pragma mark - Getting Data

-(NSArray*)getDataArray
{
    self.state = TableStateNormal;
    NSArray *array = [Contract fetchAllContractsInManagedObjectContext:[CoreDataManager sharedInstance].managedObjectContext];
    return array;
}

-(void)getDataFromAPI
{
    [super getDataFromAPI];
    [self.service GetContractsWithHeader:[GRNM1XHeader GetHeader] kco:self.kco includeWBS:NO];
}

-(void)onAPIRequestSuccess:(NSDictionary *)contractData requestType:(RequestType)requestType
{
    NSLog(@"response = %@",contractData);
    NSManagedObjectContext *context = [[CoreDataManager sharedInstance] managedObjectContext];
    NSError *error = NULL;
    NSArray *contracts = [contractData objectForKey:@"contracts"];
    NSMutableArray *contractObjectArray = [NSMutableArray array];
    if (contracts.count)
    {
        [CoreDataManager removeAllContracts];
    }
    for (NSDictionary *dict in contracts)
    {
        Contract *c = [Contract insertContractWithData:dict
                                inManagedObjectContext:context
                                                 error:&error];
        [contractObjectArray addObject:c];
    }
    self.dataArray = [self getDataArray];
    [self reloadData];
    [self.myDelegate tableDidEndLoadingData:self];
}

-(void)searchForString:(NSString*)searchString
{
    if (searchString.length)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"number CONTAINS[c] %@ OR name CONTAINS[c] %@",searchString,searchString];
        self.dataArray = [[self getDataArray] filteredArrayUsingPredicate:predicate];
    }
    else
    {
        self.dataArray = [self getDataArray];
    }
    [self reloadData];
}

@end
