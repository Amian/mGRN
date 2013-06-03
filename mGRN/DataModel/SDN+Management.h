//
//  SDN+Management.h
//  mGRN
//
//  Created by Anum on 03/06/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "SDN.h"

@interface SDN (Management)
+(void)InsertSDN:(NSString*)sdn InMOC:(NSManagedObjectContext*)moc;
+(BOOL)doesSDNExist:(NSString*)sdn inMOC:(NSManagedObjectContext*)moc;
+(void)removeExpiredSDNinMOC:(NSManagedObjectContext*)moc;

@end
