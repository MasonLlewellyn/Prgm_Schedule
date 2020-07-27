//
//  DependsObject.h
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/23/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import <Parse/Parse.h>
@class Flow;

NS_ASSUME_NONNULL_BEGIN

@interface DependsObject : PFObject <PFSubclassing>
@property (strong, nonatomic) DependsObject *dependsOn;
@property (strong, nonatomic) NSString *flowID;
@property (nonatomic) BOOL userActive;
- (BOOL) getActive;
- (void) saveToFlow: (Flow*)parentFlow completionHandler: (nullable PFBooleanResultBlock)completion;
- (void) saveToFlow:(NSString *)parentFlowID completionFunction:(PFBooleanResultBlock)completion;
@end

NS_ASSUME_NONNULL_END
