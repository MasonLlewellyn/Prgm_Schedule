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
#import "EnlargedEventViewDelegate.h"
#import "EnlargedEventView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FlowViewController : UIViewController <EnlargedEventViewDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) Flow *flow;
//@property (strong, nonatomic) NSMutableArray<Event*> *events;
@property (strong, nonatomic) NSMutableArray<LocalDependsObject*> *objects;
@property (strong, nonatomic) EnlargedEventView *currEnlargedView;
@property (nonatomic) BOOL nonEditable;
-(void) initializeView;

@end

NS_ASSUME_NONNULL_END
