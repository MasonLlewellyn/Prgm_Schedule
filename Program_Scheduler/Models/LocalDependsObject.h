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
+ (NSString*) getKind; //Static method for returning the kind of the class
- (NSString*) getKind; //Returns the kind of object that
- (void) loadAttributes;
- (void) saveToDatabase: (Flow*)flow completion:(nullable PFBooleanResultBlock)completion;
- (DependsObject*) pullDatabaseObj;
- (void) deleteDatabaseObj;
+ (NSMutableArray*) queryDependsObjects: (NSString*)flowID completion: (void(^)(NSMutableArray<LocalDependsObject *>* _Nullable objects,  NSError * _Nullable error))completion; //Querys the database for depends objects and converts them into the proper LocalDependsObject subclasses
@end

NS_ASSUME_NONNULL_END
