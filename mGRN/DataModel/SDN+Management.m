//
//  SDN+Management.m
//  mGRN
//
//  Created by Anum on 03/06/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "SDN+Management.h"

@implementation SDN (Management)

+(void)InsertSDN:(NSString*)sdn InMOC:(NSManagedObjectContext*)moc
{
    SDN *newSDN = [NSEntityDescription insertNewObjectForEntityForName:@"SDN" inManagedObjectContext:moc];
    newSDN.expiryDate = [NSDate date];
    newSDN.value = sdn;
    [moc save:nil];
}

+(BOOL)doesSDNExist:(NSString*)sdn inMOC:(NSManagedObjectContext*)moc
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SDN"];
    request.predicate = [NSPredicate predicateWithFormat:@"value LIKE[c] %@", sdn];
    NSError *fetchError = nil;
    NSArray *matches = [moc executeFetchRequest:request error:&fetchError];
    
    if ([matches count] > 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+(NSArray*)fetchAllSDNManagedObjectContext:(NSManagedObjectContext*)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SDN"];
    NSError *fetchError = nil;
    NSArray *matches = [context executeFetchRequest:request error:&fetchError];
    return matches? matches : [NSArray array];
}

+(void)removeExpiredSDNinMOC:(NSManagedObjectContext*)moc
{
    NSDate *acceptableDate = [NSDate dateWithTimeIntervalSinceNow:-60*60*60*7];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SDN"];
    request.predicate = [NSPredicate predicateWithFormat:@"expiryDate < %@", acceptableDate];
    NSError *fetchError = nil;
    NSArray *matches = [moc executeFetchRequest:request error:&fetchError];
    for (SDN *sdn in matches)
    {
//        NSLog(@"date = %@",sdn.expiryDate);
//        NSLog(@"acceptable date = %@",acceptableDate);
        [moc deleteObject:sdn];
    }
}


@end
