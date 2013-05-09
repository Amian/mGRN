//
//  Company.h
//  mgrn
//
//  Created by Peter on 23/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contract, User;

@interface Company : NSManagedObject

@property (nonatomic, retain) NSString * kco;
@property (nonatomic, retain) NSSet *contracts;
@property (nonatomic, retain) NSSet *users;
@end

@interface Company (CoreDataGeneratedAccessors)

- (void)addContractsObject:(Contract *)value;
- (void)removeContractsObject:(Contract *)value;
- (void)addContracts:(NSSet *)values;
- (void)removeContracts:(NSSet *)values;

- (void)addUsersObject:(User *)value;
- (void)removeUsersObject:(User *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

@end
