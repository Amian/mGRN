//
//  GRNBaseTable.m
//  mGRN
//
//  Created by Anum on 02/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNBaseTable.h"

@interface GRNBaseTable()
@end

@implementation GRNBaseTable
@synthesize dataArray = _dataArray,
service = _service,
reloading = _reloading,
myDelegate = _myDelegate,
selectedIndex = _selectedIndex,
state = _state;

-(M1XmGRNService*)service
{
    if (!_service)
    {
        _service = [[M1XmGRNService alloc] init];
        _service.delegate = self;
    }
    return _service;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.dataSource = self;
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

-(NSString*)kco
{
    NSString *kco = [[NSUserDefaults standardUserDefaults] objectForKey:KeyKCO];
    return [kco componentsSeparatedByString:@","].count > 0? [[kco componentsSeparatedByString:@","] objectAtIndex:0] : @"";
}

-(void)onAPIRequestFailure:(M1XResponse *)response
{
    //If communication failed, use cached data
    self.dataArray = [self getDataArray];
    [self reloadData];
    if ([self.myDelegate respondsToSelector:@selector(failedToGetData)])
        [self.myDelegate failedToGetData];
//    NSLog(@"Faliure response = %@",response);
}

-(NSArray*)getDataArray
{
    //Override this method
    return [NSArray array];
}

-(void)getDataFromAPI
{
    //Override this method to get data from API
    self.state = TableStateNormal;
    [self.myDelegate tableWillGetDataFromAPI];
}

-(void)setState:(TableState)state
{
    if (state != _state)
    {
        _state = state;
        if (state == TableStateNormal)
        {
            self.selectedIndex = nil;
        }
    }
}

-(void)reloadData
{
    [super reloadData];
    self.hidden = NO;
    self.alpha = 1.0;
//    [self.myDelegate tableDidEndLoadingData:self];
}

-(id)selectedObject
{
    NSLog(@"class = %@, count = %i",NSStringFromClass([self class]),self.dataArray.count);
    return [self.dataArray objectAtIndex:self.indexPathForSelectedRow.section];
}

-(void)rowSelected
{
    NSIndexPath *indexPath = [self indexPathForSelectedRow];
    if (indexPath.section == 0 || indexPath.section != self.selectedIndex.section)
    {
        self.selectedIndex = indexPath;
        self.state = TableStateSelected;
        [self reloadData];
    }
}

-(void)searchForString:(NSString*)searchString
{
    //Overrride method
}

-(void)doneSearching
{
    self.dataArray = [self getDataArray];
    [self reloadData];
}
@end
