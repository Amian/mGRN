//
//  RejectionReasons.h
//  mGRN
//
//  Created by Anum on 12/06/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RejectionReasons : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * codeDescription;

@end
