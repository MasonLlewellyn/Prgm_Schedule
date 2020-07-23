//
//  DependsObject.h
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/23/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface DependsObject : PFObject
- (BOOL) getActive;
@property (strong, nonatomic) DependsObject *dependsOn;
@end

NS_ASSUME_NONNULL_END
