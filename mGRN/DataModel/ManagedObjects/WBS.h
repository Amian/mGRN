//
//  WBS.h
//  mgrn
//
//  Created by Peter on 23/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contract;

@interface WBS : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * codeDescription;
@property (nonatomic, retain) NSNumber * suspense;
@property (nonatomic, retain) Contract *contract;

@end
