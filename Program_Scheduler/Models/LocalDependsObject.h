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
- (BOOL) getActive;
- (void) saveToDatabase: (DependsObject*) DatabaseObject completionHandler: (nullable PFBooleanResultBlock)completion;
@end

NS_ASSUME_NONNULL_END
