//
//  TimelineViewController.h
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/13/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
NS_ASSUME_NONNULL_BEGIN

@interface TimelineViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) User *currUser;
@end

NS_ASSUME_NONNULL_END
