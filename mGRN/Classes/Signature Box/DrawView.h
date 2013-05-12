//
//  FreeDrawView.h
//  eGRNDemo
//
//  Created by Anum on 26/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DrawViewDelegate
@optional
-(void)drawViewDidBeginDrawing;
-(void)drawViewDidEndDrawing;
@end

@interface DrawView : UIView
{
    id <DrawViewDelegate> delegate;
}
@property CGMutablePathRef path;
@property (retain) IBOutlet id delegate;
@property (nonatomic, retain) UILabel *placeholder;
-(void)clearView;
- (UIImage *)makeImage;
@end
