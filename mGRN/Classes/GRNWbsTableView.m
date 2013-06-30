//
//  GRNWbsTableView.m
//  mGRN
//
//  Created by Anum on 06/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNWbsTableView.h"
#import "WBS+Management.h"
#import "CoreDataManager.h"
#import "M1XmGRNService.h"
#import "GRNM1XHeader.h"
#import "Contract.h"

@interface GRNWbsTableView()<M1XmGRNDelegate>
@end

@implementation GRNWbsTableView
@synthesize contract = _contract;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.dataSource = self;
    }
    return self;
}

-(void)setContract:(Contract *)contract
{
    if (_contract != contract)
    {
        _contract = contract;
        self.dataArray = [WBS fetchWBSCodesForContractNumber:contract.number inMOC:[CoreDataManager moc]];
        if (!self.dataArray.count)
        {
            M1XmGRNService *service = [[M1XmGRNService alloc] init];
            service.delegate = self;
            NSString *kco = [[NSUserDefaults standardUserDefaults] objectForKey:KeyKCO];
            kco = [kco componentsSeparatedByString:@","].count > 0? [[kco componentsSeparatedByString:@","] objectAtIndex:0] : @"";
            [service GetWBSWithHeader:[GRNM1XHeader Header]
                       contractNumber:contract.number
                                  kco:kco];
        }
        else
        {
            [self reloadData];
        }
    }
}

#pragma mark - Table Data Source

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *MyIdentifier = [NSString stringWithFormat:@"MyIdentifier %i", indexPath.section];
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
        cell.indentationLevel = 1;        
        WBS *wbs = [self.dataArray objectAtIndex:indexPath.row];
        
//        cell.textLabel.text = wbs.code;
        cell.textLabel.text = [NSString stringWithFormat:@"%@: %@",wbs.code,wbs.codeDescription];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    return cell;
}

-(int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(void)onAPIRequestFailure:(M1XResponse *)response
{
    
}

-(void)onAPIRequestSuccess:(NSDictionary *)contracts requestType:(RequestType)requestType
{
    NSArray *wbsData = [contracts objectForKey:@"wbsCodes"];
    NSMutableArray *result = [NSMutableArray array];
    NSManagedObjectContext *context = [CoreDataManager moc];
    for (NSDictionary *wbs in wbsData)
    {
        [result addObject:[WBS insertWBSCodesWithData:wbs
                                          forContract:self.contract
                               inManagedObjectContext:context
                                                error:nil]];
    }
    [context save:nil];
    self.dataArray = [result copy];
    [self reloadData];
}

@end
