//
//  GRNReasonTableVC.m
//  mGRN
//
//  Created by Anum on 08/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNReasonTableVC.h"

@implementation GRNReasonTableVC

-(id)init
{
    self = [super init];
    if (self)
    {
        self.dataArray = [NSArray arrayWithObjects:@"No Reason",@"Reason 1",@"Reason 2", @"Reason 3", @"Reason 4", nil];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
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

@end
