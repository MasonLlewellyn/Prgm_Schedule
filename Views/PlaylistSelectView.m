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
    [[[NSBundle mainBundle] loadNibNamed:@"PlaylistSelectView" owner:self options:nil] objectAtIndex:0];
    
    [self addSubview:self.contentView];
    self.contentView.frame = self.bounds;
}

- (void) leaveView{
    [self removeFromSuperview];
    [self.touchInterceptView removeFromSuperview];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self leaveView];
}


- (void) interceptTapped: (UITapGestureRecognizer*)recognizer{
    //Leave the view if the intercept around the edit view is tapped
    NSLog(@"---Intercept tapped----");
    [self leaveView];
}

- (void) setupIntercept{
    NSLog(@"---Setting a faulty intercept----");
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(interceptTapped:)];
    
    tapGestureRecognizer.numberOfTapsRequired = 1;
    
    [self.touchInterceptView setUserInteractionEnabled:YES];
    [self.touchInterceptView addGestureRecognizer: tapGestureRecognizer];
}


- (void) setupAssets: (ActionObject*)actionObj touchIntercept: (UIView*)intercept{
    self.actionObj = actionObj;
    self.touchInterceptView = intercept;
    
    MPMediaQuery *mQuery = [MPMediaQuery playlistsQuery];
    NSArray<MPMediaItemCollection*> *playlists = [mQuery collections];
    
    self.playlists = playlists;
    NSLog(@"!___!__Playlist count: %lu", self.playlists.count);
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height - 100);
    
    self.tableView.center = self.contentView.center;
    
    self.contentView.layer.cornerRadius = 10;
    
    [self setupIntercept];
}

#pragma mark Table View
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *reuseID = @"cellID";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseID];
    
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
    }
    
    
    cell.textLabel.text = [self.playlists[indexPath.row] valueForProperty:MPMediaPlaylistPropertyName];
    
    NSLog(@"____text___%@", [self.playlists[indexPath.row] valueForProperty:MPMediaPlaylistPropertyName]);
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
