//
//  NSObject+Blocks.m
//  mGRN
//
//  Created by Anum on 01/07/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "NSObject+Blocks.h"

@implementation NSObject (Blocks)

- (void)performBlock:(void (^)())block
{
    block();
}

- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay
{
    void (^block_)() = [block copy]; // autorelease this if you're not using ARC
    [self performSelector:@selector(performBlock:) withObject:block_ afterDelay:delay];
}

@end