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
@dynamic author;
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

+ (void) testPostEvent{
    //This is a method that is just designed to test whether or not the Parse database can hold the class that I have defined
    //This method is not necessary for production
    
    Event* newEvent = [Event new];
    newEvent.dependsEvent = [Event new];//Can't pass null to this variable.  Right now, this signifies an empty event
    newEvent.Title = @"A meeting that could be an email";
    newEvent.isActive = YES;
    newEvent.locationLat = 0;
    newEvent.locationLong = 0;
    newEvent.locationTitle = @"Home, where the heart is";
    
    newEvent.startDateTime = [NSDate now];
    newEvent.startDateTime = [NSDate now];
    
    [newEvent saveInBackgroundWithBlock: nil];
    
}
@end
