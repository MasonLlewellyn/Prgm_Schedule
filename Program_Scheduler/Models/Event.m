//
//  Event.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/14/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "Event.h"

@implementation Event
@dynamic Title;
@dynamic startDateTime; //NOTE: might have to convert to string to store in database
@dynamic endDateTime;
@dynamic locationLat;
@dynamic locationLong;
@dynamic locationTitle;
@dynamic dependsEvent;
@dynamic isActive;

+ (nonnull NSString *)parseClassName {
    return @"Event";
}

@end
