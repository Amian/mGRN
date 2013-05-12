//
//  WBS+Management.m
//  mgrn
//
//  Created by Peter on 21/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//

#import "WBS+Management.h"
#import "Contract.h"

@implementation WBS (Management)

+(void)removeAllWBSInManagedObjectContext:(NSManagedObjectContext*)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"WBS"];
    NSError *fetchError = nil;
    NSArray *matches = [context executeFetchRequest:request error:&fetchError];
    for (id o in matches)
    {
        [context deleteObject:o];
    }
    [context save:nil];
}

+(NSArray*)fetchWBSCodesForContractNumber:(NSString*)contractNumber inMOC:(NSManagedObjectContext*)moc
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"WBS"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES]];
//    request.predicate = [NSPredicate predicateWithFormat:@"contract.number = %@", contractNumber];
    
    NSError *fetchError = nil;
    NSArray *matches = [moc executeFetchRequest:request error:&fetchError];
    return matches? matches : [NSArray array];
    
}

+(WBS*)fetchWBSWithCode:(NSString*)code inMOC:(NSManagedObjectContext*)moc
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"WBS"];
    request.predicate = [NSPredicate predicateWithFormat:@"code = %@", code];
    
    NSError *fetchError = nil;
    NSArray *matches = [moc executeFetchRequest:request error:&fetchError];
    return [matches lastObject];
    
}

+ (WBS *)insertWBSCodesWithData:(NSDictionary *)wbsData forContract:(Contract *)contract inManagedObjectContext:(NSManagedObjectContext *)context error:(NSError **)error;
{
    WBS *wbsCode = nil;
    
    if (wbsData == nil) {
        if (error != NULL) {
            // TODO: set values for error
            *error = [NSError errorWithDomain:@"" code:0 userInfo:nil];;
        }
        return nil;
    } else {
        NSString *itemNumber = [[wbsData valueForKey:M1XWBS_Code] description];
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"WBS"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES]];
        request.predicate = [NSPredicate predicateWithFormat:@"contract.number = %@ AND code = %@",contract.number, itemNumber];
        NSError *fetchError = nil;
        NSArray *matches = [context executeFetchRequest:request error:&fetchError];
        
        if (!matches || [matches count] > 1) {
            // TODO: set values for error
            if (error != NULL) {
                *error = [NSError errorWithDomain:@"" code:0 userInfo:nil];;
            }
            return nil;
        } else {
            if ([matches count] == 1)
            {
                wbsCode = [matches objectAtIndex:0];
            }
            else
            {
                wbsCode = [NSEntityDescription insertNewObjectForEntityForName:@"WBS" inManagedObjectContext:context];
                wbsCode.code = [[[wbsData valueForKey:M1XWBS_Code] description] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                wbsCode.codeDescription = [[[wbsData valueForKey:M1XWBS_Description] description] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
            [contract addWbsCodesObject:wbsCode];
            [context save:nil];
        }
    }
    return wbsCode;
}

@end
