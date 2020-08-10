//
//  PlaylistSelectView.h
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 8/7/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionObject.h"
#import <MediaPlayer/MediaPlayer.h>
NS_ASSUME_NONNULL_BEGIN

@protocol PlaylistSelectViewDelegate <NSObject>
- (void) playlistSelected: (MPMediaItemCollection*)selectedPlaylist;
- (void) playlistRemoved: (MPMediaItemCollection*)selectedPlaylist;
@end

@interface PlaylistSelectView : UIView <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, weak) id <PlaylistSelectViewDelegate> delegate;
@property (weak, nonatomic) UIView *touchInterceptView;
@property (strong, nonatomic) ActionObject* actionObj;
@property (strong, nonatomic) NSArray <MPMediaItemCollection*>* playlists;
@property (strong, nonatomic) MPMediaItemCollection* playlist;
- (void) setupAssets: (ActionObject*)actionObj touchIntercept: (UIView*)intercept;
@end

NS_ASSUME_NONNULL_END
