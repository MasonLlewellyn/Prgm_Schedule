//
//  PlaylistSelectView.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 8/7/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "PlaylistSelectView.h"

@implementation PlaylistSelectView

- (instancetype) initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    
    if (self){
        if (self.subviews.count == 0){
            [self customInit];
        }
        
    }
    
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self){
        if (self.subviews.count == 0)
            [self customInit];
    }
    
    return self;
}

- (void) customInit{
    [[[NSBundle mainBundle] loadNibNamed:@"WeatherEditView" owner:self options:nil] objectAtIndex:0];
    
    [self addSubview:self.contentView];
    self.contentView.frame = self.bounds;
}

- (void) setupAssets: (ActionObject*)actionObj{
    self.actionObj = actionObj;
    
    MPMediaQuery *mQuery = [MPMediaQuery playlistsQuery];
    NSArray<MPMediaItemCollection*> *playlists = [mQuery collections];
    
    self.playlists = playlists;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

#pragma mark Table View
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CellID"];
    
    cell.textLabel.text = [self.playlists[indexPath.row] valueForProperty:MPMediaPlaylistPropertyName];
    
    return cell;
}


- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.playlists.count;
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
