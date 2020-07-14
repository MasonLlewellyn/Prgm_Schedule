//
//  Flow.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/14/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "Flow.h"
#import "Event.h"

@implementation Flow

@dynamic flowTitle;
@dynamic author;
@dynamic events;
@dynamic active;
@dynamic startDate;
@dynamic endDate;

+ (nonnull NSString *)parseClassName {
    return @"Flow";
}

+ (void) testPostFlow{
    Flow *newFlow = [Flow new];
    newFlow.flowTitle = @"The other day";
    newFlow.startDate = [NSDate now];
    newFlow.endDate = [NSDate now];
    
    Event* newEvent = [Event new];
    newEvent.dependsEvent = [Event new];//Can't pass null to this variable.  Right now, this signifies an empty event
    newEvent.Title = @"A meeting that could be an email";
    newEvent.isActive = YES;
    newEvent.locationLat = 0;
    newEvent.locationLong = 0;
    newEvent.locationTitle = @"Home, where the heart is";
    
    newEvent.startDateTime = [NSDate now];
    newEvent.startDateTime = [NSDate now];
    
    newFlow.events = @[newEvent];
    [newFlow saveInBackgroundWithBlock:nil];
}

+ (void) testDownloadFlow{
    PFQuery *query = [Flow query];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray<Flow*> * _Nullable flows, NSError * _Nullable error) {
        if (flows){
            for (int i = 0; i < flows.count; i++){
                if ([flows[i].events[0] isKindOfClass:[Event class]])
                    NSLog(@"Its a real event");
                NSLog(@"%@: %@", flows[i].flowTitle, flows[i].events[0]);
            }
        }
        else{
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}



@end
