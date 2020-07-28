//
//  FlowEditorViewController.h
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/27/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Flow.h"
NS_ASSUME_NONNULL_BEGIN

@interface FlowEditorViewController : UIViewController
@property (strong, nonatomic) Flow *flow;
@end

NS_ASSUME_NONNULL_END
