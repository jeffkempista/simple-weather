//
//  UIView+AutoLayout.m
//  SimpleWeather
//
//  Created by Jeff Kempista on 1/11/14.
//  Copyright (c) 2014 Jeff Kempista. All rights reserved.
//

#import "UIView+AutoLayout.h"

@implementation UIView (AutoLayout)

+ (id)autoLayoutView
{
    UIView *view = [self new];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}

@end
