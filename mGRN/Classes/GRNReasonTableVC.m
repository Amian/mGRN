//
//  GRNReasonTableVC.m
//  mGRN
//
//  Created by Anum on 08/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNReasonTableVC.h"

@implementation GRNReasonTableVC

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.dataArray = [NSArray arrayWithObjects:@"No Reason",@"Damaged",@"Fragmented", @"Expect QA Details", @"Query", nil];
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
        cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
        
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

-(NSString*)selectedReason
{
    return [self.dataArray objectAtIndex:[self indexPathForSelectedRow].row];
}

-(NSString*)selectedCode
{
    NSArray *codes = [NSArray arrayWithObjects:@"", @"DA", @"FR", @"QA", @"QR", nil];
    return [codes objectAtIndex:[self indexPathForSelectedRow].row];
}

+(NSString*)ReasonForCode:(NSString*)code
{
    NSArray *array = [NSArray arrayWithObjects:@"No Reason",@"Damaged",@"Fragmented", @"Expect QA Details", @"Query", nil];
    NSArray *codes = [NSArray arrayWithObjects:@"", @"DA", @"FR", @"QA", @"QR", nil];
    int index = 0;
    for (NSString *c in codes)
    {
        if ([code isEqualToString:c])
        {
            return [array objectAtIndex:index];
        }
        index++;
    }
    return @"No Reason";
}

+(NSString*)CodeForReason:(NSString*)reason
{
    NSArray *array = [NSArray arrayWithObjects:@"No Reason",@"Damaged",@"Fragmented", @"Expect QA Details", @"Query", nil];
    NSArray *codes = [NSArray arrayWithObjects:@"", @"DA", @"FR", @"QA", @"QR", nil];
    int index = 0;
    for (NSString *c in array)
    {
        if ([reason isEqualToString:c])
        {
            return [codes objectAtIndex:index];
        }
        index++;
    }
    return @"";
}
@end
