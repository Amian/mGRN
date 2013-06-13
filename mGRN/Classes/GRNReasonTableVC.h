//
//  GRNReasonTableVC.h
//  mGRN
//
//  Created by Anum on 08/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RejectionReasons;

@interface GRNReasonTableVC : UITableView <UITableViewDataSource>
@property (nonatomic, retain) NSArray *dataArray;
-(RejectionReasons*)selectedReason;
+(RejectionReasons*)ReasonForCode:(NSString*)code;
@end
