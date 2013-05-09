//
//  FreeDrawView.m
//  eGRNDemo
//
//  Created by Anum on 26/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DrawView.h"
#import <QuartzCore/QuartzCore.h>

@interface DrawView()
@property CGMutablePathRef path;
@property CGPoint previousPoint1, previousPoint2, currentPoint;
@end

@implementation DrawView
@synthesize path = _path, previousPoint1 = _previousPoint1, previousPoint2 = _previousPoint2, currentPoint = _currentPoint;
@synthesize delegate, placeholder;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        CALayer *myLayer = [CALayer layer];
        myLayer.backgroundColor = [UIColor clearColor].CGColor;
        myLayer.borderColor = [[UIColor colorWithPatternImage:[UIImage imageNamed:@"dashed_white.png"]] CGColor];
        myLayer.borderWidth = 1.0;
        myLayer.frame = CGRectMake(0.0, self.frame.size.height*8.0/10.0, self.frame.size.width, 1.0);
        [self.layer addSublayer:myLayer];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //Redraw the path
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextStrokePath(context);
    
    if (!self.path)
        self.path = CGPathCreateMutable();
    CGContextAddPath(context, self.path);
    CGContextDrawPath(context, kCGPathStroke);
    

}

-(CGPoint)midPoint:(CGPoint)p1 and:(CGPoint) p2
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.placeholder.hidden = YES;
    [[self delegate] drawViewDidBeginDrawing];
    UITouch *touch = [touches anyObject];
    
    self.previousPoint1 = [touch previousLocationInView:self];
    self.previousPoint2 = [touch previousLocationInView:self];
    self.currentPoint = [touch locationInView:self];
    CGRect rect = CGRectMake(self.currentPoint.x - 0.5,
                             self.currentPoint.y - 0.5,
                             1.0, 1.0);
    CGPathAddEllipseInRect(self.path, NULL, rect);
    [self setNeedsDisplay];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    //The last three points are needed to make the drawing smooth and curved.
    self.previousPoint2 = self.previousPoint1;
    self.previousPoint1 = [touch previousLocationInView:self];
    self.currentPoint = [touch locationInView:self];
    CGPoint mid1 = [self midPoint:self.previousPoint1 and:self.previousPoint2]; 
    CGPoint mid2 = [self midPoint:self.currentPoint and:self.previousPoint1];
    CGPathMoveToPoint(self.path,NULL, mid1.x, mid1.y);
    CGPathAddQuadCurveToPoint(self.path, NULL, self.previousPoint1.x, self.previousPoint1.y, mid2.x, mid2.y);
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self delegate] drawViewDidEndDrawing];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self delegate] drawViewDidEndDrawing];
}

#pragma mark - Public Methods

-(void)clearView
{
    self.placeholder.hidden = NO;
    self.path = Nil;
    [self setNeedsDisplay];
}


+ (UIImage *)imageFromView:(UIView *)view
{
    CGRect viewRect = view.frame;
    UIGraphicsBeginImageContext(viewRect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGContextFillRect(ctx, viewRect);
    [view.layer renderInContext:ctx];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)makeImage
{
    return [DrawView imageFromView:self];
}

@end
