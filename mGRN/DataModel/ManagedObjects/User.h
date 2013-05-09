//
//  User.h
//  mgrn
//
//  Created by Peter on 23/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Company;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * kcoString;
@property (nonatomic, retain) NSString * m1xDomain;
@property (nonatomic, retain) NSString * m1xPassword;
@property (nonatomic, retain) NSString * m1xSessionEndDT;
@property (nonatomic, retain) NSString * m1xSessionKey;
@property (nonatomic, retain) NSString * m1xUserId;
@property (nonatomic, retain) NSSet *companies;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addCompaniesObject:(Company *)value;
- (void)removeCompaniesObject:(Company *)value;
- (void)addCompanies:(NSSet *)values;
- (void)removeCompanies:(NSSet *)values;

@end
