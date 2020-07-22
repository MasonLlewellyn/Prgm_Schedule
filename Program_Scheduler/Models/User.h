//
//  User.h
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/20/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : PFUser
@property (nonatomic, strong) PFFileObject *profileImage;
@property (nonatomic, strong) NSString *facebooKID;

@end

NS_ASSUME_NONNULL_END
