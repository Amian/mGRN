//
//  GRNWbsTableView.h
//  mGRN
//
//  Created by Anum on 06/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Contract;
@interface GRNWbsTableView : UITableView <UITableViewDataSource>
@property (nonatomic, strong) Contract *contract;
@property (nonatomic, strong) NSArray *dataArray;
@end
