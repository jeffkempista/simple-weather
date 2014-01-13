//
//  WXForecastTableViewController.h
//  SimpleWeather
//
//  Created by Jeff Kempista on 1/13/14.
//  Copyright (c) 2014 Jeff Kempista. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXForecastTableViewController : UITableViewController

@property (assign, nonatomic) CGFloat height;
@property (weak, nonatomic) id<UIScrollViewDelegate> scrollViewDelegate;

@end
