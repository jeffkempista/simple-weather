//
//  WXManager.h
//  SimpleWeather
//
//  Created by Kempista, Jeff on 1/7/14.
//  Copyright (c) 2014 Jeff Kempista. All rights reserved.
//

@import Foundation;
@import CoreLocation;
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "WXCondition.h"

@interface WXManager : NSObject <CLLocationManagerDelegate>

+ (instancetype)sharedManager;

@property (strong, readonly, nonatomic) CLLocation *currentLocation;
@property (strong, readonly, nonatomic) WXCondition *currentCondition;
@property (strong, readonly, nonatomic) NSArray *hourlyForecast;
@property (strong, readonly, nonatomic) NSArray *dailyForecast;

- (void)findCurrentLocation;

@end
