//
//  Flow.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/14/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "Flow.h"
#import "Event.h"
#import "User.h"
#import "DependsObject.h"
#import "EventObject.h"
#import "LocalDependsObject.h"
#import "WeatherObject.h"

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
    newFlow.active = NO;
    newFlow.author = [User currentUser];
    
    /*EventObject *eventObj = [EventObject new];
    eventObj.title = @"A meeting that could be an email";
    eventObj.startDate = newFlow.startDate;
    eventObj.endDate = [NSDate now];*/
    
    //NSLog(@"Pre objectID: %@", newFlow.objectId);
    [newFlow saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        /*LocalDependsObject *ldo = [LocalDependsObject new];
        [ldo saveToDatabase:newFlow completion:nil];*/
        /*WeatherObject *weatherObj = [WeatherObject new];
        weatherObj.desiredTemp = 57.02;
        [weatherObj saveToDatabase:newFlow completion:nil];*/
        
        EventObject *eventObject = [EventObject new];
        eventObject.title = @"Hoppin on train";
        eventObject.startDate = [NSDate now];
        eventObject.endDate = [NSDate now];
        [eventObject saveToDatabase:newFlow completion:nil];
    }];
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

- (void) getFlowEvents: (void(^)(NSMutableArray<LocalDependsObject *>* _Nullable objects,  NSError * _Nullable error))completion {
    /*PFQuery *eventQuery = [Event query];
    [eventQuery whereKey:@"flowID" equalTo:self.objectId];
    [eventQuery findObjectsInBackgroundWithBlock:completion];*/
    /*PFQuery *depQuery = [DependsObject query];
    [depQuery whereKey:@"flowID" equalTo:self.objectId];
    [depQuery findObjectsInBackgroundWithBlock:completion];*/
    
    [LocalDependsObject queryDependsObjects: self.objectId completion:completion];
}

- (void) copyFlow:(Flow *)givenFlow events: (NSArray*)events{
    self.flowTitle = givenFlow.flowTitle;
    self.active = givenFlow.active;
    self.startDate = givenFlow.startDate;
    self.endDate = givenFlow.endDate;
    
    [self save];
    for (unsigned long i = 0; i < events.count; i++){
        //NOTE: Is there some sort of join() method for all of these background completion handlers
        Event *e = [Event new];
        [e copyEvent:events[i]];
        [e saveEventToFlow:self completionHandler:nil];
    }
    
    NSLog(@"-----Copying this flow over-----");
    NSLog(@"Count: %lu", self.events.count);
}


@end
