//
//  UIView+THExtentsion.m
//  PageDemo
//
//  Created by SolorDreams on 2018/11/18.
//  Copyright © 2018年 SolorDreams. All rights reserved.
//

#import "UIView+THExtentsion.h"

@implementation UIView (THExtentsion)

- (void)setTh_x:(CGFloat)th_x
{
    CGRect frame = self.frame;
    frame.origin.x = th_x;
    self.frame = frame;
}

- (CGFloat)th_x
{
    return self.frame.origin.x;
}

- (void)setTh_y:(CGFloat)th_y
{
    CGRect frame = self.frame;
    frame.origin.y = th_y;
    self.frame = frame;
}

- (CGFloat)th_y
{
    return self.frame.origin.y;
}

- (void)setTh_w:(CGFloat)th_w
{
    CGRect frame = self.frame;
    frame.size.width = th_w;
    self.frame = frame;
}

- (CGFloat)th_w
{
    return self.frame.size.width;
}

- (void)setTh_h:(CGFloat)th_h
{
    CGRect frame = self.frame;
    frame.size.height = th_h;
    self.frame = frame;
}

- (CGFloat)th_h
{
    return self.frame.size.height;
}

- (void)setTh_size:(CGSize)th_size
{
    CGRect frame = self.frame;
    frame.size = th_size;
    self.frame = frame;
}

- (CGSize)th_size
{
    return self.frame.size;
}

- (void)setTh_origin:(CGPoint)th_origin
{
    CGRect frame = self.frame;
    frame.origin = th_origin;
    self.frame = frame;
}

- (CGPoint)th_origin
{
    return self.frame.origin;
}

@end
