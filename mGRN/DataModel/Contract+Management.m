//
//  Contract+Management.m
//  mgrn
//
//  Created by Peter Barclay on 20/04/2013.
//  Copyright (c) 2013 Coins Mobile. All rights reserved.
//

#import "Contract+Management.h"

@implementation Contract (Management)

+ (Contract *)insertContractWithData:(NSDictionary *)contractData inManagedObjectContext:(NSManagedObjectContext *)context error:(NSError **)error
{
    Contract *contract = nil;

    if (contractData == nil) {
        if (error != NULL) {
// TODO: set values for error
            *error = [NSError errorWithDomain:@"" code:0 userInfo:nil];;
        }
        return nil;
    } else {
        NSString *contractNumber = [[contractData valueForKey:M1XContract_Number] description];
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contract"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        request.predicate = [NSPredicate predicateWithFormat:@"number = %@", contractNumber];
        
        NSError *fetchError = nil;
        NSArray *matches = [context executeFetchRequest:request error:&fetchError];
        if (!matches || [matches count] > 1) {
// TODO: set values for error
            if (error != NULL) {
                *error = [NSError errorWithDomain:@"" code:0 userInfo:nil];;
            }
            return nil;
        } else {
            if ([matches count] == 1) {
                contract = [matches objectAtIndex:0];
//                NSLog(@"Match found for contract %@: %@", contract.number, contract.name);
            } else {
                contract = [NSEntityDescription insertNewObjectForEntityForName:@"Contract" inManagedObjectContext:context];
                contract.number = [[contractData valueForKey:M1XContract_Number] description];
                contract.name = [[contractData valueForKey:M1XContract_Name] description];
                contract.useWBS = [NSNumber numberWithBool:[[[contractData valueForKey:M1XContract_UseWBS] description] boolValue]];
                [context save:nil];
//                NSLog(@"Create contract %@: %@", contract.number, contract.name);
            }
        }
    }
    return contract;
}

+(NSArray*)fetchAllContractsInManagedObjectContext:(NSManagedObjectContext*)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contract"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES]];
    NSError *fetchError = nil;
    NSArray *matches = [context executeFetchRequest:request error:&fetchError];
    return matches? matches : [NSArray array];
}

+(void)removeAllContractsInManagedObjectContext:(NSManagedObjectContext*)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contract"];
    NSError *fetchError = nil;
    NSArray *matches = [context executeFetchRequest:request error:&fetchError];
    for (id o in matches)
    {
        [context deleteObject:o];
    }
    [context save:nil];
}

+(int)contractCountInMOC:(NSManagedObjectContext*)moc
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Contract" inManagedObjectContext:moc]];
    [request setIncludesSubentities:NO];
    NSError *err;
    NSUInteger count = [moc countForFetchRequest:request error:&err];
    if(count == NSNotFound) {
        //Handle error
    }
    return count;
}
@end
