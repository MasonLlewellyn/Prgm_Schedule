//
//  Weather.h
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/22/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
//This Weather class is a static class that should be initialized once at the start of each FlowView
static float temperature;
static NSString *conditionStr;

@interface Weather : NSObject
+ (void) initialize: (void (^)(NSError *error))completion;

+ (void) setTemperature: (float)tempValue;
+ (float) getTemperature;

+ (void) setConditionStr: (NSString*)condition;
+ (NSString*) getConditionStr;

+ (void) testWeather;
+ (void) getWeather: (void (^)(NSError *error, Weather *weather))completion;//Gets the current weather
@end

NS_ASSUME_NONNULL_END
