//
//  TimelineViewController.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/13/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "TimelineViewController.h"
#import <Parse/Parse.h>
#import "Event.h"
#import "Flow.h"
#import "FlowFeedTableViewCell.h"
#import "LoginViewController.h"
#import "FlowViewController.h"
#import "SceneDelegate.h"
#import "AppDelegate.h"
#import "FlowEditorViewController.h"
#import "NotificationUtils.h"
#import <CKLoadingView/CKLoadingView.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <DGActivityIndicatorView/DGActivityIndicatorView.h>
#import <MediaPlayer/MediaPlayer.h>

@interface TimelineViewController () <FlowEditDelegate, MPMediaPickerControllerDelegate>
@property (nonatomic, strong) NSMutableArray *activeFlows;
@property (nonatomic, strong) NSMutableArray *inactiveFlows;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *profileButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *friendsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addFlowButton;
@property (strong, nonatomic) IBOutlet CKLoadingView *loadingView;

@property (nonatomic) CKLoadingView *timelineLoadingView;
@property (nonatomic) DGActivityIndicatorView *activityIndicator;

@property (assign, nonatomic) BOOL isMoreDataLoading;
@property (assign, nonatomic) NSInteger loadedCount;
@end

//NSString *HeaderViewIdentifier = @"TableViewHeaderView";
NSInteger pageCount = 20;

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshFlows:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:refreshControl atIndex:0];
    
    if (self.showOther){
        [self.friendsButton setEnabled:NO];
        [self.logoutButton setEnabled:NO];
        [self.profileButton setEnabled:NO];
        [self.profileButton setEnabled:NO];
        
        [self.friendsButton setTintColor:[UIColor clearColor]];
        [self.logoutButton setTintColor:[UIColor clearColor]];
        [self.profileButton setTintColor:[UIColor clearColor]];
        [self.addFlowButton setTintColor:[UIColor clearColor]];
        
        UIColor *fbColor = [UIColor colorWithRed:59/255.0 green:89/255.0 blue:152/255.0 alpha:1.0];
        [self.navigationController.navigationBar setBackgroundColor:fbColor];
        self.title = @"Flows";
    }
    else if (!self.showOther && self.currUser == nil){
        NSLog(@"Taking matters into my own hands");
        self.currUser = [User currentUser];
    }
    
    
                            
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    //[Flow testPostFlow];
    //[Event cleanHouse];
    
    //Request notification Auth
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions options = UNAuthorizationOptionAlert+UNAuthorizationOptionSound;
    [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
        
    }];
    
    /*self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.activityIndicator.center = self.view.center;
    
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];*/
    
    //[self setupLoadingView];
    
    //self.tableView.hidden = YES;
    
    self.activityIndicator = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeNineDots tintColor:UIColor.redColor size:50.0f];
    self.activityIndicator.frame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
    self.activityIndicator.center = self.view.center;
    [self.view addSubview:self.activityIndicator];
    
    [self fetchFlows];
    [self musiq_test];
}

- (void) musiq_test{
    /*MPMediaPickerController *pickControl = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    
    //pickControl.allowsPickingMultipleItems = YES;
    pickControl.popoverPresentationController.sourceView = self.view;
    pickControl.delegate = self;
    [self presentViewController:pickControl animated:YES completion:^{
        
    }];*/
    
    MPMediaQuery *mQuery = [MPMediaQuery playlistsQuery];
    NSArray<MPMediaItemCollection*> *playlists = [mQuery collections];
    
    NSLog(@"!!!!!!Playlist count %lu!!!!!!!!!", playlists.count);
    for (unsigned long i = 0; i < playlists.count; i++){
        NSLog(@"!!!!!!!%@", [playlists[i] valueForProperty:MPMediaPlaylistPropertyName]);
        NSLog(@"!!!!!!!%@", [playlists[i] valueForProperty:MPMediaPlaylistPropertyPersistentID]);
    }
    
    /*MPMusicPlayerController *mControl = [MPMusicPlayerApplicationController systemMusicPlayer];
    [mControl setQueueWithItemCollection:playlists[playlists.count - 1]];
    [mControl play];*/
}

- (void) setupLoadingView{
    //TODO: Loading view is not displaying...Maybe set up with sotryboard instead
    self.timelineLoadingView = [[CKLoadingView alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth([UIScreen mainScreen].bounds), 200)];
    
    self.timelineLoadingView.center = self.view.center;
    self.timelineLoadingView.animationSpeed = 0.5;
    self.timelineLoadingView.animationItemDelayInterval = 0.1;
    self.timelineLoadingView.animationStopWaitInterval = 0.1;
    
    //self.timelineLoadingView.backgroundColor = UIColor.brownColor;
    self.timelineLoadingView.loadingShape = CKLoadingShapeRectangle;
    [self.timelineLoadingView startAnimate];
    [self.view addSubview:self.timelineLoadingView];
    //[self.view addSubview:self.timelineLoadingView];
    
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self fetchFlows];
}
- (void) refreshFlows:(UIRefreshControl*)refreshControl{
    [self fetchFlows];
    [refreshControl endRefreshing];
}
- (IBAction)addFlowPressed:(id)sender {
    [self performSegueWithIdentifier:@"TimelineToEditor" sender:nil];
}

- (IBAction)logoutPressed:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        sceneDelegate.window.rootViewController = loginViewController;
    }];
}
- (IBAction)profileButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"timelineToProfileView" sender:nil];
}
- (IBAction)friendsButtonPressed:(id)sender {
    //IF the user is already logged into Facebook (Perform some action)
    if ([FBSDKAccessToken currentAccessToken]) {
        //TODO: print a list of all friends on the application
        [self performSegueWithIdentifier:@"timelineToFriends" sender:nil];
    }
    else{
        NSLog(@"There is no Faceboook account so I can't really help you");
    }
}

- (void)fetchFlows{
    if (self.showOther && !self.currUser){
        NSLog(@"No user so I can't get anything");
        return;
    }
    __weak typeof(self) weakSelf = self;
    
    [self.activityIndicator startAnimating];
    
    PFQuery *query = [Flow query];
    query.limit = pageCount;
    //[actQuery whereKey:@"active" equalTo:[NSNumber numberWithBool:YES]];
    [query whereKey:@"author" equalTo:self.currUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray<Flow*> * _Nullable flows, NSError * _Nullable error) {
        if (flows){
            weakSelf.activeFlows = [NSMutableArray arrayWithArray:flows];
            weakSelf.loadedCount = weakSelf.activeFlows.count;
            
            NSLog(@"-------Stop animation called----");
            //[weakSelf.timelineLoadingView removeFromSuperview];
            
            //self.tableView.hidden = NO;
            [self.activityIndicator stopAnimating];
            [weakSelf.activityIndicator stopAnimating];
            [weakSelf.tableView reloadData];
        }
        else{
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void) fetchMoreFlows{
    if (self.showOther && !self.currUser){
        NSLog(@"No user so I can't get anything");
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    PFQuery *query = [Flow query];
    query.skip = self.loadedCount;
    query.limit = pageCount;
    [query whereKey:@"author" equalTo:self.currUser];
    //[actQuery whereKey:@"active" equalTo:[NSNumber numberWithBool:YES]];
    [query findObjectsInBackgroundWithBlock:^(NSArray<Flow*> * _Nullable flows, NSError * _Nullable error) {
        if (flows){
            [weakSelf.activeFlows addObjectsFromArray:flows];
            weakSelf.loadedCount = weakSelf.activeFlows.count;
            weakSelf.isMoreDataLoading = false;
            [weakSelf.tableView reloadData];
        }
        else{
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

#pragma mark MPMediaPickerView
- (void) mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection{
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
    
    MPMusicPlayerController *mControl = [MPMusicPlayerApplicationController systemMusicPlayer];
    [mControl setQueueWithItemCollection:mediaItemCollection];
    [mControl play];
}

- (void) mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[FlowFeedTableViewCell class]]){
        FlowFeedTableViewCell *cell = sender;
        FlowViewController *controller = [segue destinationViewController];
        
        //If the current user is looking at someone else's flow, they shouldn't be able to edit it
        if ([User currentUser] != self.currUser){
            NSLog(@"I'm not feeling like myself");
            controller.nonEditable = YES;
        }
        
        controller.flow = cell.flow;
    }
    else if ([segue.identifier isEqualToString:@"TimelineToEditor"]){
        //User is maing a new flow
        FlowEditorViewController *controller = [segue destinationViewController];
        controller.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"cellToFlowView"]){
        //TODO: condensce this with the FlowFeedCell conditions
        FlowViewController *controller = [segue destinationViewController];
        Flow *sentFlow = sender;
        
        if ([User currentUser] != self.currUser){
            NSLog(@"I'm not feeling like myself");
            controller.nonEditable = YES;
        }
        
        controller.flow = sentFlow;
    }
    else{
        //User is making a profile view
    }
}

#pragma mark FlowEditorView

- (void) editFlowSaved:(FlowEditorViewController *)fvc{
    [self performSegueWithIdentifier:@"cellToFlowView" sender:fvc.flow];
}

#pragma mark -Table View
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    NSMutableArray *arr = nil;
    if (indexPath.section == 0)
        arr = self.activeFlows;
    else if (indexPath.section == 1){
        NSLog(@"using the inactive array");
        arr = self.inactiveFlows;
    }
        
    Flow *currFlow = arr[indexPath.row];
    FlowFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"feedCell"];
    
    [cell setupCell:currFlow];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.activeFlows.count;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(!self.isMoreDataLoading){

        int scrollViewContentHeight = self.tableView.contentSize.height;
        int scrollOffsetThreshold = scrollViewContentHeight - self.tableView.bounds.size.height;
        
        
        if(scrollView.contentOffset.y > scrollOffsetThreshold && self.tableView.isDragging) {
            self.isMoreDataLoading = true;
            NSLog(@"Reached bottom.  More data being loaded");
            [self fetchMoreFlows];
        }
    }

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return !self.showOther;
}

//Delete all of the events in a given flow
- (void) removeAssociatedEvents: (Flow*) flow{
    [flow getFlowEvents:^(NSArray<EventObject*> * _Nullable events, NSError * _Nullable error) {
        if (error){
            NSLog(@"%@", error.localizedDescription);
        }
        else{
            //Delete all events in the array
            for (NSInteger i = 0; i < events.count; i++){
                [events[i] deleteDatabaseObj];
            }
        }
    }];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //remove the deleted object from your data source.
        //If your data source is an NSMutableArray, do this
        Flow *removedFlow = self.activeFlows[indexPath.row];
        
        //Delete all associated depends objects
        [self removeAssociatedEvents:removedFlow];
        [removedFlow deleteInBackground];
        
        //Delete the flow itself
        [self.activeFlows removeObjectAtIndex:indexPath.row];
        [tableView reloadData]; // tell table to refresh now
    }
}

@end
