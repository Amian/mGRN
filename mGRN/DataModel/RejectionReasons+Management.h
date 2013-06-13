//
//  RejectionReasons+RejectionReasons_Management.h
//  mGRN
//
//  Created by Anum on 12/06/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "RejectionReasons.h"

@interface RejectionReasons (Management)

+(void)insertRejectionReasonsWithDictionary:(NSDictionary*)reasonDict inMOC:(NSManagedObjectContext*)moc;
+(NSArray*)getAllRejectionReasonsInMOC:(NSManagedObjectContext*)moc;
+(void)removeAllRejectionReasonsInMOC:(NSManagedObjectContext*)moc;
+(RejectionReasons*)fetchReasonWithCode:(NSString*)code inMOC:(NSManagedObjectContext*)moc;

@end
