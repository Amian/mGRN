//
//  RejectionReasons+RejectionReasons_Management.m
//  mGRN
//
//  Created by Anum on 12/06/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "RejectionReasons+Management.h"

@implementation RejectionReasons (Management)

+(void)insertRejectionReasonsWithDictionary:(NSDictionary *)reasonDict inMOC:(NSManagedObjectContext *)moc
{
    RejectionReasons *rr = [NSEntityDescription insertNewObjectForEntityForName:@"RejectionReasons" inManagedObjectContext:moc];
    rr.code = [reasonDict objectForKey:@"code"];
    rr.codeDescription = [reasonDict objectForKey:@"description"];
}

+(NSArray*)getAllRejectionReasonsInMOC:(NSManagedObjectContext *)moc
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"RejectionReasons"];
    
    NSError *fetchError = nil;
    NSArray *matches = [moc executeFetchRequest:request error:&fetchError];
    return matches;
}

+(void)removeAllRejectionReasonsInMOC:(NSManagedObjectContext*)moc
{
    NSArray *reasons = [RejectionReasons getAllRejectionReasonsInMOC:moc];
    for (RejectionReasons *rr in reasons)
    {
        [moc deleteObject:rr];
    }
}

+(RejectionReasons*)fetchReasonWithCode:(NSString*)code inMOC:(NSManagedObjectContext*)moc
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"RejectionReasons"];
    request.predicate = [NSPredicate predicateWithFormat:@"code LIKE[c] %@",code];
    NSError *fetchError = nil;
    NSArray *matches = [moc executeFetchRequest:request error:&fetchError];
    return [matches lastObject];

}

@end
