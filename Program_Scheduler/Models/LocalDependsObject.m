//
//  LocalDependsObject.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/23/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "LocalDependsObject.h"

@implementation LocalDependsObject

- (NSString*) getKind{
    return @"LocalObj";
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

//The translation method
+ (NSMutableArray*) queryDependsObjects{
    return [NSMutableArray alloc];
}
@end
