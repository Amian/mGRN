//
//  GRNReasonTableVC.m
//  mGRN
//
//  Created by Anum on 08/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNReasonTableVC.h"
#import "RejectionReasons+Management.h"
#import "CoreDataManager.h"
#import "M1XmGRNService.h"
#import "GRNM1XHeader.h"
#import "LoadingView.h"

@interface GRNReasonTableVC()<M1XmGRNDelegate>
@property (nonatomic, strong) UIView *loadingView;
@end

@implementation GRNReasonTableVC

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.dataArray = [RejectionReasons getAllRejectionReasonsInMOC:[CoreDataManager moc]];
        if (!self.dataArray.count)
        {
            [self getReasonsFromAPI];
        }
        self.dataSource = self;
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
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.text = [(RejectionReasons*)[self.dataArray objectAtIndex:indexPath.row] codeDescription];
        
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

-(float)rowHeight
{
    return self.frame.size.height/5;
}

-(RejectionReasons*)selectedReason
{
    return [self.dataArray objectAtIndex:[self indexPathForSelectedRow].row];
}

+(RejectionReasons*)ReasonForCode:(NSString*)code
{
    return [RejectionReasons fetchReasonWithCode:code inMOC:[CoreDataManager moc]];
}

-(void)getReasonsFromAPI
{
    self.loadingView = [LoadingView loadingViewWithFrame:self.frame];
    [self addSubview:self.loadingView];
    M1XmGRNService *service = [[M1XmGRNService alloc] init];
    service.delegate = self;
    NSString *kco = [[NSUserDefaults standardUserDefaults] objectForKey:KeyKCO];
    kco = [kco componentsSeparatedByString:@","].count > 0? [[kco componentsSeparatedByString:@","] objectAtIndex:0] : @"";
    [service GetRejectionReasonsWithHeader:[GRNM1XHeader Header]
                                       kco:kco];
}

-(void)onAPIRequestSuccess:(NSDictionary *)response requestType:(RequestType)requestType
{
    NSArray *reasons = [response objectForKey:@"reasons"];
    NSManagedObjectContext *context = [CoreDataManager moc];
    for (NSDictionary *r in reasons)
    {
        [RejectionReasons insertRejectionReasonsWithDictionary:r inMOC:[CoreDataManager moc]];
    }
    self.dataArray = [RejectionReasons getAllRejectionReasonsInMOC:context];
    [context save:nil];
    [self.loadingView removeFromSuperview];
    [self reloadData];
}

-(void)onAPIRequestFailure:(M1XResponse *)response
{
    [self.loadingView removeFromSuperview];
}

@end
