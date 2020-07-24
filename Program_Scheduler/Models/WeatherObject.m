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
@dynamic desiredTemp;
@dynamic desiredCondition;

- (NSString*) getKind{
    return @"WeatherObj";
}

- (BOOL) getActive{
    float tolerance = 5.0;
    float temp = [Weather getTemperature];
    BOOL tempGood = ((self.desiredTemp - tolerance) >= temp && temp <= (self.desiredTemp + tolerance));//Temperature is += (tolerance) degrees from set point
    
    BOOL condGood = [conditionStr isEqualToString:self.desiredCondition];
    
    return (tempGood && condGood);
}

- (void)saveToDatabase:(Flow *)flow completion:(PFBooleanResultBlock)completion{
    DependsObject *dObj = [self pullDatabaseObj];
    dObj[@"kind"] = [self getKind];
    dObj[@"desiredTemp"] = [NSString stringWithFormat:@"%f", self.desiredTemp];
    dObj[@"desiredCondition"] = self.desiredCondition;
}
@end
