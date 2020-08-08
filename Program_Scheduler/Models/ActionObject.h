//
//  ActionObject.h
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 8/7/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "EventObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface ActionObject : EventObject
@property (strong, nonatomic) NSString *playlistTitle;
@property (strong, nonatomic) NSString *playlistID;
@end

NS_ASSUME_NONNULL_END
