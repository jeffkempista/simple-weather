//
//  WXClient.h
//  SimpleWeather
//
//  Created by Kempista, Jeff on 1/7/14.
//  Copyright (c) 2014 Jeff Kempista. All rights reserved.
//

@import Foundation;
@import CoreLocation;
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface WXClient : NSObject

- (RACSignal *)fetchJSONFromURL:(NSURL *)url;
- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate;
- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate;
- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate;

@end
