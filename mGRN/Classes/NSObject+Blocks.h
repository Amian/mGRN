//
//  NSObject+Blocks.h
//  mGRN
//
//  Created by Anum on 01/07/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Blocks)

- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay;

@end