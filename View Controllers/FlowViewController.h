//
//  FlowViewController.h
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/15/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Flow.h"
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface FlowViewController : UIViewController
@property (strong, nonatomic) Flow *flow;
@property (strong, nonatomic) NSMutableArray<Event*> *events;
@end

NS_ASSUME_NONNULL_END
