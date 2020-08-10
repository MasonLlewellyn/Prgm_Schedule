//
//  playlistUtil.h
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 8/8/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ActionObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface playlistUtil : NSObject
+ (void) playIDPlaylist: (NSString*)playlistID;
@end

NS_ASSUME_NONNULL_END
