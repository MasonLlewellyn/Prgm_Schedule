//
//  ImageUploadViewController.h
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/20/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ImageUploadViewControllerDelegate
- (void)didPost;
@end

@interface ImageUploadViewController : UIViewController
@property (nonatomic, weak) id<ImageUploadViewControllerDelegate> delegate;
@property (nonatomic, strong) ProfileViewController *profileView;
@end

NS_ASSUME_NONNULL_END
