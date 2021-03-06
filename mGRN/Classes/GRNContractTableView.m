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
    NSArray *array = [Contract fetchAllContractsInManagedObjectContext:[CoreDataManager moc]];
    return array;
}

-(void)getDataFromAPI
{
    if (self.sessionExpired)
    {
        [self.myDelegate failedToGetData:self];
        return;
    }
    [super getDataFromAPI];
    [self.service GetContractsWithHeader:[GRNM1XHeader Header] kco:self.kco includeWBS:NO];
}

-(void)onAPIRequestSuccess:(NSDictionary *)contractData requestType:(RequestType)requestType
{
    //    NSLog(@"response = %@",contractData);
    NSManagedObjectContext *context = [CoreDataManager moc];
    NSError *error = NULL;
    NSArray *contracts = [contractData objectForKey:@"contracts"];
    NSMutableArray *contractObjectArray = [NSMutableArray array];
    if (contracts.count)
    {
        [CoreDataManager removeData:NO];
    }
    for (NSDictionary *dict in contracts)
    {
        Contract *c = [Contract insertContractWithData:dict
                                inManagedObjectContext:context
                                                 error:&error];
        [contractObjectArray addObject:c];
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
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"number CONTAINS[c] %@ OR name CONTAINS[c] %@",searchString,searchString];
        self.dataArray = [[self getDataArray] filteredArrayUsingPredicate:predicate];
    }
    else
    {
        self.dataArray = [self getDataArray];
    }
    [self reloadData];
}

-(void)selectContractWithNumber:(NSString*)number
{
    NSPredicate *p = [NSPredicate predicateWithFormat:@"number LIKE %@",number];
    Contract *c = [[self.dataArray filteredArrayUsingPredicate:p] lastObject];
    if (c)
    {
        NSIndexPath *index = [NSIndexPath indexPathForRow:0  inSection:[self.dataArray indexOfObject:c]];
        [self selectRowAtIndexPath:index animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}
    @end
