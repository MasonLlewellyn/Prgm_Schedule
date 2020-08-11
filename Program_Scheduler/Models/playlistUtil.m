//
//  playlistUtil.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 8/8/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "playlistUtil.h"

@implementation playlistUtil

+ (MPMediaItemCollection*) playlistForID: (NSNumber*)playlistID{
    MPMediaQuery *mQuery = [MPMediaQuery playlistsQuery];
    NSArray<MPMediaItemCollection*> *playlists = [mQuery collections];
    
    for (unsigned long i = 0; i < playlists.count; i++){
        NSNumber *playNum = [playlists[i] valueForProperty:MPMediaPlaylistPropertyPersistentID];
        
        unsigned long divNum = [playNum unsignedLongValue] / 1000;
        unsigned long divID = [playlistID unsignedLongValue] / 1000;
        
        
        if (divID == divNum){
            return playlists[i];
        }
    }
    
    return nil;
}

+ (void) playIDPlaylist: (NSNumber*)playlistID{
    MPMediaItemCollection *actionList = [self playlistForID:playlistID];
    
    MPMusicPlayerController *mControl = [MPMusicPlayerApplicationController systemMusicPlayer];
    [mControl setQueueWithItemCollection:actionList];
    [mControl play];
}

@end
