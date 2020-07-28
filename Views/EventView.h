//
//  EventView.h
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/15/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "EventObject.h"
#import "FlowViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EventView : UIView <UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
//@property (strong, nonatomic) Event* event;
@property (strong, nonatomic) EventObject* eventObj;
@property (weak, nonatomic) FlowViewController *flowVC;
@property (nonatomic) BOOL nonEditable;
- (void) setupAssets: (EventObject*)event flowViewController:(FlowViewController*)flowControl;
- (void) leaveView;
@end

NS_ASSUME_NONNULL_END
