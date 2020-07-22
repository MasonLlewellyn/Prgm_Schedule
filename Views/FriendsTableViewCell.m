//
//  FriendsTableViewCell.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/21/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "FriendsTableViewCell.h"

@implementation FriendsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setupCell:(NSDictionary *)userInfo{
    self.usernameLabel.text = userInfo[@"name"];
    self.userInfo = userInfo;
}

@end
