//
//  EnlargedEventView.h
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/16/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "EventObject.h"
#import "ActionObject.h"
#import "EnlargedEventViewDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface EnlargedEventView : UIView
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dependsTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UISwitch *activeSwitch;
@property (weak, nonatomic) IBOutlet UILabel *playlistLabel;

@property (weak, nonatomic) UIView *touchInterceptView;
@property (weak, nonatomic) EventObject *eventObj;

@property (nonatomic, weak) id <EnlargedEventViewDelegate> delegate;
@property (nonatomic) BOOL nonEditable;
- (void)setupAssets: (EventObject*)eventObj intercept: (UIView*)touchIntercept;
- (void)setupDisplay: (EventObject*)eventObj;
@end




NS_ASSUME_NONNULL_END
