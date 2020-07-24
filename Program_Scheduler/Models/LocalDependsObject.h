//
//  LocalDependsObject.h
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/23/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DependsObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface LocalDependsObject : NSObject
@property (strong, nonatomic) LocalDependsObject *dependsOn;
@property (strong, nonatomic) NSString *flowID;
@property (strong, nonatomic) DependsObject *databaseObj;
- (BOOL) getActive;
- (NSString*) getKind; //Returns the kind of object that
- (void) loadAttributes;
- (void) saveToDatabase: (Flow*)flow completion:(nullable PFBooleanResultBlock)completion;
- (DependsObject*) pullDatabaseObj;

+ (NSMutableArray*) queryDependsObjects; //Querys the database for depends objects and converts them into the proper LocalDependsObject subclasses
@end

NS_ASSUME_NONNULL_END
