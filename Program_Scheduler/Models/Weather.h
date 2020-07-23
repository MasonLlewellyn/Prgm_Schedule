//
//  Weather.h
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/22/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Weather : NSObject
@property (nonatomic, strong) NSString *conditionStr;
@property (nonatomic) float temperature;
+ (void) testWeather;
+ (void) getWeather: (void (^)(NSError *error, Weather *weather))completion;//Gets the current weather
@end

NS_ASSUME_NONNULL_END
