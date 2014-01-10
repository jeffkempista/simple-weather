//
//  WXController.m
//  SimpleWeather
//
//  Created by Kempista, Jeff on 1/7/14.
//  Copyright (c) 2014 Jeff Kempista. All rights reserved.
//

#import "WXController.h"

#import "WXManager.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>

@interface WXController ()

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIImageView *blurredImageView;
@property (strong, nonatomic) UITableView *tableView;
@property (assign, nonatomic) CGFloat screenHeight;

@property (strong, nonatomic) NSDateFormatter *hourlyFormatter;
@property (strong, nonatomic) NSDateFormatter *dailyFormatter;

@end

@implementation WXController

- (id)init
{
    if (self = [super init]) {
        _hourlyFormatter = [[NSDateFormatter alloc] init];
        _hourlyFormatter.dateFormat = @"h a";
        
        _dailyFormatter = [[NSDateFormatter alloc] init];
        _dailyFormatter.dateFormat = @"EEEE";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // 1
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    UIImage *background = [UIImage imageNamed:@"bg"];
    
    // 2
    self.backgroundImageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView;
    });
    [self.view addSubview:self.backgroundImageView];
    
    // 3
    self.blurredImageView = ({
        UIImageView *imageView = [UIImageView new];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.alpha = 0;
        [imageView setImageToBlur:background blurRadius:10 completionBlock:nil];
        imageView;
    });
    [self.view addSubview:self.blurredImageView];
    
    // 4
    self.tableView = ({
        UITableView *tableView = [UITableView new];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
        tableView.pagingEnabled = YES;
        tableView;
    });
    [self.view addSubview:self.tableView];
    
    // 1
    CGRect headerFrame = [UIScreen mainScreen].bounds;
    // 2
    CGFloat inset = 20;
    // 3
    CGFloat temperatureHeight = 110;
    CGFloat hiloHeight = 40;
    CGFloat iconHeight = 30;
    //4
    CGRect hiloFrame = CGRectMake(inset, headerFrame.size.height - hiloHeight, headerFrame.size.width - (2 * inset), hiloHeight);
    
    CGRect temperatureFrame = CGRectMake(inset, headerFrame.size.height - (temperatureHeight + hiloHeight), headerFrame.size.width - (2 * inset), temperatureHeight);
    
    CGRect iconFrame = CGRectMake(inset, temperatureFrame.origin.y - iconHeight, iconHeight, iconHeight);
    
    // 5
    CGRect conditionsFrame = iconFrame;
    conditionsFrame.size.width = self.view.bounds.size.width - (((2 * inset) + iconHeight) + 10);
    conditionsFrame.origin.x = iconFrame.origin.x + (iconHeight + 10);
    
    // 1
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
    // 2
    // bottom left
    UILabel *temperatureLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:temperatureFrame];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.text = @"0°";
        label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:120];
        label;
    });
    [header addSubview:temperatureLabel];
    
    // bottom left
    UILabel *hiloLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:hiloFrame];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.text = @"0° / 0°";
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
        label;
    });
    [header addSubview:hiloLabel];
    
    UILabel *cityLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 30)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.text = @"Loading...";
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        label.textAlignment = NSTextAlignmentCenter;
        label;
    });
    [header addSubview:cityLabel];
    
    UILabel *conditionsLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:conditionsFrame];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.text = @"Clear";
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        label;
    });
    [header addSubview:conditionsLabel];
    
    // 3
    // bottom left
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    iconView.image = [UIImage imageNamed:@"weather-clear"];
    iconView.contentMode = UIViewContentModeScaleAspectFill;
    iconView.backgroundColor = [UIColor clearColor];
    [header addSubview:iconView];
    
    [[RACObserve([WXManager sharedManager], currentCondition)
        deliverOn:[RACScheduler mainThreadScheduler]]
    subscribeNext:^(WXCondition *newCondition) {
        temperatureLabel.text = [NSString stringWithFormat:@"%.0f°", newCondition.temperature.floatValue];
        conditionsLabel.text = [newCondition.condition capitalizedString];
        cityLabel.text = [newCondition.locationName capitalizedString];

        iconView.image = [UIImage imageNamed:[newCondition imageName]];
    }];
    
    [[RACObserve([WXManager sharedManager], dailyForecast)
        deliverOn:[RACScheduler mainThreadScheduler]]
    subscribeNext:^(NSArray *dailyConditions) {
        [self.tableView reloadData];
    }];
    
    [[RACObserve([WXManager sharedManager], hourlyForecast)
        deliverOn:[RACScheduler mainThreadScheduler]]
    subscribeNext:^(NSArray *hourlyConditions) {
         [self.tableView reloadData];
    }];

    RAC(hiloLabel, text) = [[RACSignal combineLatest:@[
                            RACObserve([WXManager sharedManager], currentCondition.tempHigh),
                            RACObserve([WXManager sharedManager], currentCondition.tempLow)]
                            reduce:^(NSNumber *hi, NSNumber *low) {
                                return [NSString stringWithFormat:@"%.0f° / %.0f°", hi.floatValue, low.floatValue];
                            }]
                            deliverOn:[RACScheduler mainThreadScheduler]];
    [[WXManager sharedManager] findCurrentLocation];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
    self.tableView.frame = bounds;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return MIN([[WXManager sharedManager].hourlyForecast count], 6) + 1;
    }
    return MIN([[WXManager sharedManager].dailyForecast count], 6) + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    // Setup the cell
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Hourly Forecast"];
        } else {
            WXCondition *weather = [WXManager sharedManager].hourlyForecast[indexPath.row + 1];
            [self configureHourlyCell:cell weather:weather];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Daily Forecast"];
        } else {
            WXCondition *weather = [WXManager sharedManager].dailyForecast[indexPath.row + 1];
            [self configureDailyCell:cell weather:weather];
        }
    }
    
    return cell;
}

- (void)configureHeaderCell:(UITableViewCell *)cell title:(NSString *)title
{
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
}

- (void)configureHourlyCell:(UITableViewCell *)cell weather:(WXCondition *)weather {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.hourlyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f°", weather.temperature.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)configureDailyCell:(UITableViewCell *)cell weather:(WXCondition *)weather {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.dailyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f° / %.0f°", weather.tempHigh.floatValue, weather.tempLow.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    return self.screenHeight / (CGFloat)cellCount;
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    
    CGFloat percent = MIN(position / height, 1.0);
    
    self.blurredImageView.alpha = percent;
}

@end
