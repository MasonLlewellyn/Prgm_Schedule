//
//  FriendsTableViewCell.h
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/21/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FriendsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) NSDictionary *userInfo;
- (void) setupCell: (NSDictionary*)userInfo;
@end

NS_ASSUME_NONNULL_END
