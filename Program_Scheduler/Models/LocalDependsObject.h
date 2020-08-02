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
@property (nonatomic) BOOL userActive; // Whether or not the user has switched an event to be active or inactive
@property (nonatomic) BOOL cachedResult;
@property (nonatomic) BOOL cacheDone;

- (BOOL) getActive;
- (BOOL) cacheActive; //Caches the state of the event and returns whether or not the
- (BOOL) getCached;
+ (NSString*) getKind; //Static method for returning the kind of the class
- (NSString*) getKind; //Returns the kind of object that
- (void) loadAttributes;
- (void) saveToDatabase: (Flow*)flow completion:(nullable PFBooleanResultBlock)completion;
- (void) updateSave: (nullable PFBooleanResultBlock)completion; //When you've 
- (DependsObject*) pullDatabaseObj;
- (void) deleteDatabaseObj;
- (instancetype) copy;


+ (NSMutableArray*) queryDependsObjects: (NSString*)flowID completion: (void(^)(NSMutableArray<LocalDependsObject *>* _Nullable objects,  NSError * _Nullable error))completion; //Querys the database for depends objects and converts them into the proper LocalDependsObject subclasses

@end

NS_ASSUME_NONNULL_END
