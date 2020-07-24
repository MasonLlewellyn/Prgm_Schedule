//
//  WeatherObject.h
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/23/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "DependsObject.h"
#import "LocalDependsObject.h"
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeatherObject : LocalDependsObject
@property (nonatomic) float desiredTemp;
@property (strong, nonatomic) NSString *desiredCondition;
@end

NS_ASSUME_NONNULL_END
