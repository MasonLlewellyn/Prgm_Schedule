//
//  FlowFeedTableViewCell.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/14/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "FlowFeedTableViewCell.h"
#import "NotificationUtils.h"
@implementation FlowFeedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setupCell: (Flow*) flow{
    self.titleLabel.text = flow.flowTitle;
    self.descriptionLabel.text = @"";
    
    [self.activeSwitch setOn:flow.active];
    self.flow = flow;
}
- (IBAction)switchValueChanged:(id)sender {
    //Update the active/inactive state of switch
    NSLog(@"Shuffle ball change");
    UISwitch *swi = sender;
    self.flow.active = swi.isOn;
    
    if (self.flow.active)
        [NotificationUtils loadFlowNotifications:self.flow];
    else
        [NotificationUtils removeFlowNotifications:self.flow];
    [self.flow saveInBackground];
}

@end
