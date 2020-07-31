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
#import "NotificationUtils.h"

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

#pragma mark Flow Testing
+ (void) testPostFlow{
    Flow *newFlow = [Flow new];
    newFlow.flowTitle = @"The other day";
    newFlow.startDate = [NSDate now];
    newFlow.endDate = [NSDate now];
    newFlow.active = YES;
    newFlow.author = [User currentUser];
    
    /*EventObject *eventObj = [EventObject new];
    eventObj.title = @"A meeting that could be an email";
    eventObj.startDate = newFlow.startDate;
    eventObj.endDate = [NSDate now];*/
    
    //NSLog(@"Pre objectID: %@", newFlow.objectId);
    [newFlow saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        /*LocalDependsObject *ldo = [LocalDependsObject new];
        [ldo saveToDatabase:newFlow completion:nil];*/
        WeatherObject *weatherObj = [WeatherObject new];
        weatherObj.desiredTemp = 308.88;
        [weatherObj saveToDatabase:newFlow completion:nil];
        
        EventObject *eventObject = [EventObject new];
        eventObject.title = @"Go for an early run";
        eventObject.startDate = [NSDate now];
        eventObject.endDate = [NSDate now];
        eventObject.userActive = YES;
        eventObject.dependsOn = weatherObj;
        
        [eventObject saveToDatabase:newFlow completion:^(BOOL succeeded, NSError * _Nullable error) {
            EventObject *secEvent = [EventObject new];
            secEvent.title = @"Buy more CLIF Bars from the convenience store";
            secEvent.startDate = [NSDate now];
            secEvent.endDate = [NSDate now];
            secEvent.dependsOn = eventObject;
            secEvent.userActive = YES;
            [secEvent saveToDatabase:newFlow completion:nil];
            
            NSLog(@"Bet it all! Half was never the agreement!");
        }];
        
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
    [LocalDependsObject queryDependsObjects: self.objectId completion:completion];
}

/*- (void) copyFlow:(Flow *)givenFlow events: (NSArray*)events{
    self.flowTitle = givenFlow.flowTitle;
    self.active = givenFlow.active;
    self.startDate = givenFlow.startDate;
    self.endDate = givenFlow.endDate;
    
    [self save];
    for (unsigned long i = 0; i < events.count; i++){
        //NOTE: Is there some sort of join() method for all of these background completion handlers
        
        /*Event *e = [Event new];
        [e copyEvent:events[i]];
        [e saveEventToFlow:self completionHandler:nil];
    }
    
    NSLog(@"-----Copying this flow over-----");
    NSLog(@"Count: %lu", self.events.count);
}*/


- (void) copyFlow:(Flow *)givenFlow events:(NSArray<LocalDependsObject*>*)dependsObjs{
    self.flowTitle = givenFlow.flowTitle;
    self.active = givenFlow.active;
    self.startDate = givenFlow.startDate;
    self.endDate = givenFlow.endDate;
    
    NSMapTable *oldToNew = [[NSMapTable alloc] initWithKeyOptions: NSMapTableWeakMemory valueOptions: NSMapTableStrongMemory capacity:dependsObjs.count];
    
    
}

- (void) evaluateObjects: (void(^)(NSMutableArray<LocalDependsObject *>* _Nullable objects,  NSError * _Nullable error))completion{
    [self getFlowEvents:^(NSMutableArray<LocalDependsObject *> * _Nullable objects, NSError * _Nullable error) {
        if (error){
            NSLog(@"Evaluate error: %@", objects);
        }
        else{
            for (unsigned long i = 0; i < objects.count; i++){
                [objects[i] getActive]; //This function will cache the
            }
        }
        
        //self.dependsObjects = objects;
        completion(objects, error);
    }];
}

- (void) updateEvaluations:(void (^)(LocalDependsObject * _Nonnull))misMatchHandler completion:(void (^)(NSMutableArray<LocalDependsObject *> * _Nullable, NSError * _Nullable))completion{
    //TODO implement me
}

#pragma mark Notifications

@end
