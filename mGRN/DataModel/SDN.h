//
//  SDN.h
//  mGRN
//
//  Created by Anum on 03/06/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SDN : NSManagedObject

@property (nonatomic, retain) NSDate * expiryDate;
@property (nonatomic, retain) NSString * value;

@end
