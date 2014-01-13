//
//  WXController.m
//  SimpleWeather
//
//  Created by Kempista, Jeff on 1/7/14.
//  Copyright (c) 2014 Jeff Kempista. All rights reserved.
//

#import "WXController.h"

#import "WXForecastTableViewController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>

@interface WXController ()

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIImageView *blurredImageView;
@property (strong, nonatomic) WXForecastTableViewController *forecastViewController;

@end

@implementation WXController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIImage *background = [UIImage imageNamed:@"bg"];
    
    // 2
    self.backgroundImageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
        [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView;
    });
    [self.view addSubview:self.backgroundImageView];
    
    // 3
    self.blurredImageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
        [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.alpha = 0;
        [imageView setImageToBlur:background blurRadius:10 completionBlock:nil];
        imageView;
    });
    [self.view addSubview:self.blurredImageView];
    
    self.forecastViewController = ({
        WXForecastTableViewController *forecastViewController = [[WXForecastTableViewController alloc] initWithStyle:UITableViewStylePlain];
        [forecastViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
        forecastViewController.scrollViewDelegate = self;
        [self.view addSubview:forecastViewController.view];
        [self addChildViewController:forecastViewController];
        /*
        UIView *headerView = forecastViewController.tableView.tableHeaderView;
        CGRect headerFrame = headerView.frame;
        headerFrame.size.height = self.view.frame.size.height;
        headerView.frame = headerFrame;
        forecastViewController.tableView.tableHeaderView = headerView;
        */
        forecastViewController;
    });
    
    NSDictionary *views = @{@"backgroundImageView": self.backgroundImageView, @"blurredImageView": self.blurredImageView, @"tableView": self.forecastViewController.tableView};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[backgroundImageView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundImageView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[blurredImageView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[blurredImageView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[tableView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView]|" options:0 metrics:nil views:views]];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillLayoutSubviews
{
    CGRect bounds = self.view.bounds;
    self.forecastViewController.height = bounds.size.height;
    self.forecastViewController.tableView.frame = bounds;
    if (self.forecastViewController.tableView.tableHeaderView) {
        UIView *headerView = self.forecastViewController.tableView.tableHeaderView;
        CGRect headerFrame = headerView.frame;
        headerFrame.size.height = CGRectGetHeight(bounds);
        headerView.frame = headerFrame;
        [self.forecastViewController.tableView setTableHeaderView:headerView];
    }
    [super viewWillLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    
    CGFloat percent = MIN(position / height, 1.0);

    self.blurredImageView.alpha = percent * 2;
}

@end
