//
//  FlowFeedTableViewCell.h
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/14/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Flow.h"

NS_ASSUME_NONNULL_BEGIN

@interface FlowFeedTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) Flow* flow;
@property (weak, nonatomic) IBOutlet UISwitch *activeSwitch;

- (void) setupCell: (Flow*)flow;

@end

NS_ASSUME_NONNULL_END
