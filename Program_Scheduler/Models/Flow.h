//
//  Flow.h
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/14/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import <Parse/Parse.h>
#import "Event.h"
#import "LocalDependsObject.h"
#import <UserNotifications/UserNotifications.h>

NS_ASSUME_NONNULL_BEGIN

@interface Flow : PFObject<PFSubclassing>

@property (strong, nonatomic) NSString *flowTitle;
@property (strong, nonatomic) NSArray *events;
@property (strong, nonatomic) PFUser *author;
@property (nonatomic) BOOL active;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

+ (void) testPostFlow;
+ (void) testDownloadFlow;
- (void) copyFlow: (Flow*)givenFlow events: (NSArray*)events;
- (void) getFlowEvents: (void(^)(NSMutableArray<LocalDependsObject *>* _Nullable objects,  NSError * _Nullable error))completion;

- (void) evaluateObjects: (void(^)(NSMutableArray<LocalDependsObject *>* _Nullable objects,  NSError * _Nullable error))completion; //Evaluate all of the events in the flow with a completion handler.  This should be a drop-in replacement for the getFlowEventsFunction
- (void) setNotifications: (NSArray<LocalDependsObject*>*)objects; //Set all notifications for the flow
@end

NS_ASSUME_NONNULL_END
