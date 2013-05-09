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
@property (nonatomic, strong) Contract *contract;
@end

@implementation GRNWbsTableView
@synthesize contract = _contract;

-(id)initWithFrame:(CGRect)frame contract:(Contract*)contract
{
    self = [super init];
    if (self) {
        self.contract = contract;
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(108,400);
        self.dataArray = [WBS fetchWBSCodesForContractNumber:contract.number inMOC:[CoreDataManager sharedInstance].managedObjectContext];
        if (!self.dataArray.count)
        {
            M1XmGRNService *service = [[M1XmGRNService alloc] init];
            service.delegate = self;
            NSString *kco = [[NSUserDefaults standardUserDefaults] objectForKey:KeyKCO];
            kco = [kco componentsSeparatedByString:@","].count > 0? [[kco componentsSeparatedByString:@","] objectAtIndex:0] : @"";
            [service GetWBSWithHeader:[GRNM1XHeader GetHeader]
                       contractNumber:contract.number
                                  kco:kco];
        }
        self.tableView.dataSource = self;
        self.view.backgroundColor = [UIColor blackColor];
    }
    return self;
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
        
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        
        WBS *wbs = [self.dataArray objectAtIndex:indexPath.section];
        
        cell.textLabel.text = wbs.code;
        cell.detailTextLabel.text = wbs.codeDescription;
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

-(void)onGetContractsFailure:(M1XResponse *)response
{
    
}

-(void)onGetContractsSuccess:(NSDictionary *)contracts
{
    NSArray *wbsData = [contracts objectForKey:@"wbsCodes"];
    NSMutableArray *result = [NSMutableArray array];
    for (NSDictionary *wbs in wbsData)
    {
        [result addObject:[WBS insertWBSCodesWithData:wbs
                        forContract:self.contract
             inManagedObjectContext:[CoreDataManager sharedInstance].managedObjectContext
                              error:nil]];
    }
    self.dataArray = [result copy];
    [self.tableView reloadData];
}

@end
