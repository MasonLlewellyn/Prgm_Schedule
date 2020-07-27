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
    return YES;
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
    
    //TODO: Make sure all of the data is loaded to the database of the parent object
    dObj.dependsOn = self.dependsOn.databaseObj;
    [self loadAttributes];
    [dObj saveToFlow:flow completionHandler:completion];
}

- (void)deleteDatabaseObj{
    if (self.databaseObj)
        [self.databaseObj deleteInBackground];
}

//Given the objectID, perform a linear search over the full list of downloaded objects
+ (DependsObject*) getFullObject: (NSString*)objectID objects: (NSArray<DependsObject*>*)objects{
    if (!objectID) return nil;
    for (unsigned long i = 0; i < objects.count; i++){
        if ([objects[i].objectId isEqualToString:objectID]) return objects[i];
    }
    return nil;
}

//TODO: Figure out how to copy the dependency tree without duplications
+ (LocalDependsObject*) databaseToLocal: (DependsObject*)dbObject{
    NSString *kindStr = dbObject[@"kind"]; //TODO: Error:Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'Key "kind" has no data.  Call fetchIfNeeded before getting its value.'
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
        eObj.title = dbObject[@"title"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
        //formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
        
        eObj.startDate = dbObject[@"startDate"];
        eObj.endDate = dbObject[@"endDate"];
        return eObj;
    }
    //As a last resort, just instantiate it a a LocalDatabaseObject
    LocalDependsObject *lObj = [LocalDependsObject new];
    lObj.databaseObj = dbObject;
    return lObj;
}
//Traces and sets up dependencies as far as it can for each object
+ (LocalDependsObject*) setupObject: (DependsObject*)dependsObject dependsMap: (NSMapTable*)dependsMap objectsArr: (NSArray<DependsObject*>*)objectsArr{
    if ([dependsMap objectForKey:dependsObject]){
        return [dependsMap objectForKey:dependsObject];
    }
    
    NSLog(@"---------CurrObj: %@", dependsObject);
    LocalDependsObject *originalObj = [LocalDependsObject databaseToLocal:dependsObject];
    
    NSMutableArray *depStack = [[NSMutableArray alloc] init];
    [depStack addObject:dependsObject];
    [dependsMap setObject:originalObj forKey:dependsObject];
    
    LocalDependsObject *currLocal = originalObj;
    //We can imitate recusion without using as much mememory by using a stack
    while (depStack.count > 0){
        DependsObject *currDep = [depStack lastObject];
        [depStack removeLastObject];
        //Resolve the full dependency object
        currDep.dependsOn = [self getFullObject:currDep.dependsOn.objectId objects:objectsArr];
        if (currDep.dependsOn){
            
            
            NSLog(@"--------DependsON: %@", currDep.dependsOn);
            if (![dependsMap objectForKey:currDep.dependsOn]){
                [dependsMap setObject:[LocalDependsObject databaseToLocal:currDep.dependsOn] forKey:currDep.dependsOn];
                [depStack addObject:currDep.dependsOn];
            }
            currLocal.dependsOn = [dependsMap objectForKey:currDep.dependsOn];
        }
    }
    
    return originalObj;
}

//The translation method
+ (NSMutableArray*) queryDependsObjects: (NSString*)flowID completion: (void(^)(NSMutableArray<LocalDependsObject *>* _Nullable objects,  NSError * _Nullable error))completion{
    
    
    PFQuery *query = [DependsObject query];
    //[actQuery whereKey:@"active" equalTo:[NSNumber numberWithBool:YES]];
    [query whereKey:@"flowID" equalTo:flowID];
    [query findObjectsInBackgroundWithBlock:^(NSArray<DependsObject*> * _Nullable objects, NSError * _Nullable error) {
        //NSMutableDictionary *dependsMap = [NSMutableDictionary dictionary];
        NSMapTable *dependsMap = [[NSMapTable alloc] initWithKeyOptions: NSMapTableWeakMemory valueOptions: NSMapTableStrongMemory capacity:objects.count];
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        if (!error){
            for (unsigned long i = 0; i < objects.count; i++){
                //If this object has already been created
                LocalDependsObject *lObj = [self setupObject:objects[i] dependsMap:dependsMap objectsArr:objects];//[LocalDependsObject databaseToLocal:objects[i]];
                
                [array addObject: lObj];
            }
        }
        completion(array, error);
    }];
    
    return [NSMutableArray alloc];
}
@end
