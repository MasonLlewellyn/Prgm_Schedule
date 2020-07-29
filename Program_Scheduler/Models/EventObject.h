//
//  EventObject.h
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/23/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "DependsObject.h"
#import "LocalDependsObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface EventObject : LocalDependsObject
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (nonatomic) BOOL userBool; //Boolean value that checks whether the user has activated the event

- (BOOL) compareEvent: (EventObject*) otherEvent; //Return whether or not the two events are equal, the main criterias now are title and date
@end

NS_ASSUME_NONNULL_END
