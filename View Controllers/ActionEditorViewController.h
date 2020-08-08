//
//  ActionEditorViewController.h
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 8/7/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventEditorViewController.h"
#import "Flow.h"
#import "EventObject.h"
#import "Weather.h"
#import "WeatherObject.h"
#import "ActionObject.h"


NS_ASSUME_NONNULL_BEGIN

@interface ActionEditorViewController : EventEditorViewController
@property (strong, nonatomic) ActionObject *actionObj;

@end

NS_ASSUME_NONNULL_END
