//
//  GRNReasonTableVC.h
//  mGRN
//
//  Created by Anum on 08/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GRNReasonTableVC : UITableView <UITableViewDataSource>
@property (nonatomic, retain) NSArray *dataArray;
-(NSString*)selectedReason;
-(NSString*)selectedCode;
+(NSString*)CodeForReason:(NSString*)reason;
+(NSString*)ReasonForCode:(NSString*)code;
@end
