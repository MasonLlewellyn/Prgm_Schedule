//
//  LocalDependsObject.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/23/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "LocalDependsObject.h"
#import "WeatherObject.h"
#import "EventObject.h"

@implementation LocalDependsObject

+ (NSString*) getKind{
    return @"LocalObj";
}

- (NSString*) getKind{
    return [LocalDependsObject getKind];
}
- (BOOL) getActive{
    if (self.dependsOn){
        return [self.dependsOn getActive];
    }
    //Not active otherwise
    return NO;
}

- (DependsObject*) pullDatabaseObj{
    if (!self.databaseObj)
        self.databaseObj = [DependsObject new];
    return self.databaseObj;
}

- (void) loadAttributes{
    if (!self.databaseObj)
        self.databaseObj = [DependsObject new];
    
    self.databaseObj[@"kind"] = [self getKind];
    
    DependsObject *dependDatabase = self.databaseObj;
    if (dependDatabase.objectId)
        self.databaseObj[@"dependsOn"] = dependDatabase.objectId;
}

- (void) saveToDatabase: (Flow*)flow completion: (PFBooleanResultBlock)completion{
    DependsObject *dObj = [self pullDatabaseObj];
    [self loadAttributes];
    [dObj saveToFlow:flow completionHandler:completion];
}

//TODO: Figure out how to copy the dependency tree without duplications
+ (LocalDependsObject*) databaseToLocal: (DependsObject*)dbObject{
    NSString *kindStr = dbObject[@"kind"];
    if ([kindStr isEqualToString:[WeatherObject getKind]]){
        //If the thing is a weather object
        WeatherObject *wObj = [WeatherObject new];
        wObj.databaseObj = dbObject;
        wObj.desiredCondition = dbObject[@"desiredCondition"];
        wObj.desiredTemp = [dbObject[@"desiredTemp"] floatValue];
        return wObj;
    }
    else if ([kindStr isEqualToString:[EventObject getKind]]){
        //If it is an event
        EventObject *eObj = [EventObject new];
        eObj.databaseObj = dbObject;
        return eObj;
    }
    //As a last resort, just instantiate it a a LocalDatabaseObject
    LocalDependsObject *lObj = [LocalDependsObject new];
    lObj.databaseObj = dbObject;
    return lObj;
}
//The translation method
+ (NSMutableArray*) queryDependsObjects:  (void(^)(NSMutableArray<LocalDependsObject *>* _Nullable objects,  NSError * _Nullable error))completion{
    //TODO: Add completionhandler
    PFQuery *query = [DependsObject query];
    //[actQuery whereKey:@"active" equalTo:[NSNumber numberWithBool:YES]];
    //[query whereKey:@"author" equalTo:self.currUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray<DependsObject*> * _Nullable objects, NSError * _Nullable error) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        if (!error){
            for (unsigned long i = 0; i < objects.count; i++){
                LocalDependsObject *lObj = [LocalDependsObject databaseToLocal:objects[i]];
                [array addObject: lObj];
            }
        }
        completion(array, error);
    }];
    
    return [NSMutableArray alloc];
}
@end
