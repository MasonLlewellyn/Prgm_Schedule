//
//  WeatherEditView.h
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/28/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeatherObject.h"
#import "EventObject.h"
#import "Flow.h"
#import "WeatherEditDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface WeatherEditView : UIView <UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *temperatureField;
@property (weak, nonatomic) IBOutlet UIPickerView *conditionPickerView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (weak, nonatomic) UIView *touchInterceptView;
@property (strong, nonatomic) WeatherObject *weatherObj;
@property (strong, nonatomic) EventObject *eventObj;
@property (strong, nonatomic) NSArray<NSString*> *conditionStrings;
@property (strong, nonatomic) Flow *flow;
@property (nonatomic, weak) id <WeatherEditViewDelegate> delegate;

- (void) setupAssets: (WeatherObject*)weatherObj eventObject:(EventObject*)eventObj intercept: (UIView*)touchIntercept;
@end

NS_ASSUME_NONNULL_END
