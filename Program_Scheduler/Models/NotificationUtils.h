//
//  NotificationUtils.h
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/30/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalDependsObject.h"
#import "EventObject.h"
#import "ActionObject.h"
#import "Flow.h"

NS_ASSUME_NONNULL_BEGIN

@interface NotificationUtils : NSObject
+ (void) loadNotification: (EventObject*) eventObj;
+ (void) removeNotification: (EventObject*)eventObj;
+ (void) removeFlowNotifications: (Flow*)eventObj; //remove all notificatoins in a given flow

+ (void) loadFlowNotifications: (Flow*)flow; //NOTE: this currently evaluates the flow but there may be some room for optimization here
+ (void) registerActions;
@end

NS_ASSUME_NONNULL_END
