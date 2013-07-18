//
//  LoadingView.m
//  mGRN
//
//  Created by Anum on 12/05/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "LoadingView.h"
#import <QuartzCore/QuartzCore.h>
@implementation LoadingView

+(UIView*)loadingViewWithFrame:(CGRect)frame
{
    UIView *baseView = [[UIView alloc] initWithFrame:frame];
    baseView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    
    UIView *loadingView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 200.0)];
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    loadingView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
    loadingView.center = baseView.center;
    loadingView.layer.cornerRadius = 35.0;
    loadingView.layer.borderColor = [UIColor blackColor].CGColor;
    loadingView.layer.borderWidth = 2.0;
    loadingView.clipsToBounds = YES;
    [baseView addSubview:loadingView];
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activity.center = CGPointMake(loadingView.frame.size.width/2,
                                  loadingView.frame.size.height/2);
    [activity startAnimating];
    [loadingView addSubview:activity];
    return baseView;
}
@end
