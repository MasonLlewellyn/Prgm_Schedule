//
//  EventEditorViewController.h
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/16/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "Flow.h"

NS_ASSUME_NONNULL_BEGIN

@interface EventEditorViewController : UIViewController
@property (strong, nonatomic) Event *event;
@property (strong, nonatomic) Flow *flow;
@end

NS_ASSUME_NONNULL_END
