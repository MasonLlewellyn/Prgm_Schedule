//
//  FlowFeedTableViewCell.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/14/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "FlowFeedTableViewCell.h"

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
    self.descriptionLabel.text = @"Unavialable";
    
    self.flow = flow;
}

@end
