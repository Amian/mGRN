//
//  GRNDataOperation.m
//  mGRN
//
//  Created by Anum on 13/06/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNDataOperation.h"

@implementation GRNDataOperation

- (void)main {
    // a lengthy operation
    @autoreleasepool {
        for (int i = 0 ; i < 100000000 ; i++) {
            NSLog(@"%f", sqrt(i));
        }
    }
}
@end
