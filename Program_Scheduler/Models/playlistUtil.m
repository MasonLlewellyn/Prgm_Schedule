//
//  playlistUtil.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 8/8/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "playlistUtil.h"

@implementation playlistUtil

+ (MPMediaItemCollection*) playlistForID: (NSString*)playlistID{
    MPMediaQuery *mQuery = [MPMediaQuery playlistsQuery];
    NSArray<MPMediaItemCollection*> *playlists = [mQuery collections];
    
    for (unsigned long i = 0; i < playlists.count; i++){
        [playlists[i] valueForProperty:MPMediaPlaylistPropertyPersistentID];
        
        if ([[playlists[i] valueForProperty:MPMediaPlaylistPropertyPersistentID] isEqual:playlistID]){
            return playlists[i];
        }
    }
    
    return nil;
}

+ (void) playIDPlaylist: (NSString*)playlistID{
    MPMediaItemCollection *actionList = [self playlistForID:playlistID];
    
    MPMusicPlayerController *mControl = [MPMusicPlayerApplicationController systemMusicPlayer];
    [mControl setQueueWithItemCollection:actionList];
    [mControl play];
}

@end
