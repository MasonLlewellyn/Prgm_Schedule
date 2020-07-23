//
//  Event.h
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/14/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import <Parse/Parse.h>
@class Flow;

NS_ASSUME_NONNULL_BEGIN

@interface Event : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *Title;
@property (nonatomic, strong) PFUser *author;
@property (nonatomic, strong) NSDate *startDateTime; //NOTE: might have to convert to string to store in database
@property (nonatomic, strong) NSDate *endDateTime;
@property (nonatomic) NSInteger locationLat;
@property (nonatomic) NSInteger locationLong;
@property (nonatomic, strong) NSString *locationTitle;
@property (nonatomic, strong) Event *dependsEvent;
@property (nonatomic, strong) NSString* flowID;
@property (nonatomic) BOOL isActive;

+ (void) testPostEvent;
+ (void) testDownloadEvent;
+ (Event*) dummyEvent;
- (void) saveEventToFlow: (Flow*)parentFlow completionHandler: (nullable PFBooleanResultBlock)completion;
- (void) copyEvent: (Event*)givenEvent;
@end

NS_ASSUME_NONNULL_END
