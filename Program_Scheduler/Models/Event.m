//
//  Event.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/14/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "Event.h"
#import "Flow.h"
#import "User.h"

@implementation Event
@dynamic Title;
@dynamic author;
@dynamic startDateTime; //NOTE: might have to convert to string to store in database
@dynamic flowID;
@dynamic endDateTime;
@dynamic locationLat;
@dynamic locationLong;
@dynamic locationTitle;
@dynamic dependsEvent;
@dynamic isActive;




+ (nonnull NSString *)parseClassName {
    return @"Event";
}

- (void) saveEventToFlow: (Flow*)parentFlow completionHandler: (nullable PFBooleanResultBlock)completion{
    self.flowID = parentFlow.objectId;
    if (completion == nil){
        [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {}];
    }
    else{
        [self saveInBackgroundWithBlock:completion];
    }
}

- (void) copyEvent:(Event *)givenEvent{
    //NOTE: Omit copying the FlowID because we are copying this event to a new flow,
    //Also, omitting the dependency copy because we will
    self.Title = givenEvent.Title;
    self.author = [User currentUser];
    self.startDateTime = givenEvent.startDateTime;
    self.endDateTime = givenEvent.endDateTime;
    self.locationLat = givenEvent.locationLat;
    self.locationLong = givenEvent.locationLong;
    self.isActive = givenEvent.isActive;
}

+ (void) testPostEvent{
    //This is a method that is just designed to test whether or not the Parse database can hold the class that I have defined
    //This method is not necessary for production
    
    Event* newEvent = [self dummyEvent];
    NSLog(@"Event print %@", newEvent);
    [newEvent saveInBackgroundWithBlock: nil];
}

+ (void) testDownloadEvent{
    // construct PFQuery
    PFQuery *postQuery = [Event query];
    [postQuery orderByDescending:@"createdAt"];
    //[postQuery includeKey:@"author"];
    postQuery.limit = 20;

    // fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Event *> * _Nullable events, NSError * _Nullable error) {
        if (events) {
            // do something with the data fetched
            for (int i = 0; i < events.count; i++){
                NSLog(@"%@", events[i].Title);
            }
            
        }
        else {
            // handle error
        }
    }];
}

+ (Event*) dummyEvent{
    Event* newEvent = [Event new];
    newEvent.dependsEvent = [Event new];//Can't pass null to this variable.  Right now, this signifies an empty event
    newEvent.Title = @"A meeting that could be an email";
    newEvent.isActive = YES;
    newEvent.locationLat = 0;
    newEvent.locationLong = 0;
    newEvent.locationTitle = @"Home, where the heart is";
    
    newEvent.startDateTime = [NSDate now];
    newEvent.endDateTime = [NSDate now];
    
    return newEvent;
}

+ (void) getEventFromID: (NSString*)eventID eventPointer:(Event *__autoreleasing *)eventPt{
    PFQuery *eQuery = [Event query];
    [eQuery whereKey:@"objectID" equalTo:eventID];
    [eQuery findObjectsInBackgroundWithBlock:^(NSArray<Event*>* _Nullable events, NSError * _Nullable error) {
        //There should only be one event in the array
        if (events.count > 0){
            *eventPt = events[0];
        }
        
    }];
}

+ (void) cleanHouse{
    PFQuery *eQuery = [Event query];
    [eQuery whereKeyDoesNotExist:@"flowID"];
    [eQuery findObjectsInBackgroundWithBlock:^(NSArray<Event*>* _Nullable events, NSError * _Nullable error) {
        NSLog(@"----------Clearing House------------------------------");
        for (unsigned long i = 0; i < events.count; i++){
            [events[i] deleteInBackground];
        }
        NSLog(@"------------We did it guys, we deleted all the orphans----------------");
    }];
}
@end
