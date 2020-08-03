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

/*- (LocalDependsObject*) copyObj: (LocalDependsObject*)obj dependsMap: (NSMapTable*)dependsMap{
    
}*/


//TODO: Copy database objects
- (LocalDependsObject*) resolveObject: (LocalDependsObject*)obj dependsMap: (NSMapTable*)dependsMap{
    if ([dependsMap objectForKey:obj]){
        return [dependsMap objectForKey:obj];
    }
    
    NSMutableArray<LocalDependsObject*> *depStack = [[NSMutableArray alloc] init];
    [depStack addObject: obj];
    
    //TODO: update the depends fields of database objects to point to one another
    while (depStack.count > 0){
        LocalDependsObject *currObj = [depStack lastObject];
        [depStack removeLastObject];
        
        LocalDependsObject *opObj = [currObj copy];
        [opObj loadAttributes];
        
        if (currObj.dependsOn){
            if (![dependsMap objectForKey:currObj.dependsOn]){
                [dependsMap setObject:[currObj.dependsOn copy] forKey:currObj.dependsOn];
                [depStack addObject:currObj.dependsOn];
            }
            
            opObj.dependsOn = [dependsMap objectForKey:currObj.dependsOn];
        }
        
        [dependsMap setObject:opObj forKey:currObj];
    }
    return [dependsMap objectForKey:obj];
}

- (void) copyFlow:(Flow *)givenFlow events:(NSArray<LocalDependsObject*>*)dependsObjs{
    self.flowTitle = givenFlow.flowTitle;
    self.active = givenFlow.active;
    self.startDate = givenFlow.startDate;
    self.endDate = givenFlow.endDate;
    
    NSMapTable *oldToNew = [[NSMapTable alloc] initWithKeyOptions: NSMapTableWeakMemory valueOptions: NSMapTableStrongMemory capacity:dependsObjs.count];
    
    NSMutableArray <LocalDependsObject*> *newObjects = [[NSMutableArray alloc] initWithCapacity:dependsObjs.count];
    
    NSLog(@"Count: %lu", dependsObjs.count);
    
    for (unsigned int i = 0; i < dependsObjs.count; i++){
        LocalDependsObject *newObj = [self resolveObject:dependsObjs[i] dependsMap:oldToNew];
        [newObjects addObject:newObj];
    }
    
    //After all new objects are initialized, also initialize their database objects
    //Note: every parent must be saved before every child so that objectIDs work

    
    [self save];//Save the Parent flow so that it has an ID
    
    //Save all db objects in the foreground to create ObjectIDs
    for (unsigned int j = 0; j < newObjects.count; j++){
        newObjects[j].databaseObj.flowID = self.objectId;
        NSLog(@"%@", newObjects[j].databaseObj);
        [newObjects[j].databaseObj save];
    }
    
    //Establish connections between all objects
    for (unsigned int k = 0; k < newObjects.count; k++){
        newObjects[k].databaseObj.dependsOn = newObjects[k].dependsOn.databaseObj;
        [newObjects[k].databaseObj save];
    }
    
    NSLog(@"---------------------Finished Copying-------------------");
    
}

- (void) evaluateObjects: (void(^)(NSMutableArray<LocalDependsObject *>* _Nullable objects,  NSError * _Nullable error))completion{
    [self getFlowEvents:^(NSMutableArray<LocalDependsObject *> * _Nullable objects, NSError * _Nullable error) {
        if (error){
            NSLog(@"Evaluate error: %@", objects);
        }
        else{
            for (unsigned long i = 0; i < objects.count; i++){
                [objects[i] cacheActive]; //This function will cache the
            }
        }
        
        //self.dependsObjects = objects;
        completion(objects, error);
    }];
}

- (void) updateEvaluations: (NSArray<LocalDependsObject*>*)objects mismatchHandler:(void(^)(LocalDependsObject *eventObj))mismatchHandler{
    //TODO implement me
    
    for (unsigned long i = 0; i < objects.count; i++){
        if (![objects[i] cacheActive]){
            mismatchHandler(objects[i]);
        }
    }
    
    
}

//search the list of events (no query here) and get the events that are children of the given event
+ (NSArray<EventObject*>*) getChildren: (EventObject*)parentObj objects:(NSArray<LocalDependsObject*>*)objects{
    
    NSArray<EventObject*> *opArr = (NSArray<EventObject*>*)[objects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ((EventObject*)evaluatedObject).dependsOn == parentObj;
    }]];
    
    return opArr;
}

+ (BOOL) hasEventWithTitle: (EventObject*)saveObj objects: (NSArray<EventObject*>*)objects{
    for (unsigned long i = 0; i < objects.count; i++){
        if (objects[i] != saveObj && [objects[i].title isEqualToString:saveObj.title]) return YES;
    }
    
    return NO;
}

#pragma mark Notifications

@end
