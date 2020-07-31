//
//  WeatherObject.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/23/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "WeatherObject.h"
#import "Weather.h"

@implementation WeatherObject

+ (NSString*) getKind{
    return @"WeatherObj";
}

- (NSString*) getKind{
    return [WeatherObject getKind];
}
- (BOOL) getActive{
    float tolerance = 5.0;
    float temp = [Weather getTemperature];
    BOOL tempGood = ((self.desiredTemp - tolerance) <= temp && temp <= (self.desiredTemp + tolerance));//Temperature is += (tolerance) degrees from set point
    
    BOOL condGood = TRUE;//[conditionStr isEqualToString:self.desiredCondition];
    
    return (tempGood && condGood);
}

- (void)saveToDatabase:(Flow *)flow completion:(PFBooleanResultBlock)completion{
    DependsObject *dObj = [self pullDatabaseObj];
    dObj[@"kind"] = [self getKind];
    dObj[@"desiredTemp"] = [NSString stringWithFormat:@"%f", self.desiredTemp];
    if (self.desiredCondition)
        dObj[@"desiredCondition"] = self.desiredCondition;
    
    [dObj saveToFlow:flow completionHandler:completion];
}

- (instancetype) copy{
    WeatherObject *newObj = [WeatherObject new];
    
    newObj.desiredCondition = [self.desiredCondition copy];
    newObj.desiredTemp = self.desiredTemp;
    
    return newObj;
}

@end
