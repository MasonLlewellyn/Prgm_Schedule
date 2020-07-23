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

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface TimelineViewController ()
@property (nonatomic, strong) NSMutableArray *activeFlows;
@property (nonatomic, strong) NSMutableArray *inactiveFlows;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *profileButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *friendsButton;

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
        
        [self.friendsButton setTintColor:[UIColor clearColor]];
        [self.logoutButton setTintColor:[UIColor clearColor]];
        [self.profileButton setTintColor:[UIColor clearColor]];
        self.title = @"Flows";
    }
    else if (!self.showOther && self.currUser == nil){
        NSLog(@"Taking matters into my own hands");
        self.currUser = [User currentUser];
    }
    
    //[Flow testPostFlow];
    [self fetchFlows];
    
    
    
}

- (void) refreshFlows:(UIRefreshControl*)refreshControl{
    [self fetchFlows];
    [refreshControl endRefreshing];
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
    PFQuery *query = [Flow query];
    query.limit = pageCount;
    //[actQuery whereKey:@"active" equalTo:[NSNumber numberWithBool:YES]];
    [query whereKey:@"author" equalTo:self.currUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray<Flow*> * _Nullable flows, NSError * _Nullable error) {
        if (flows){
            weakSelf.activeFlows = [NSMutableArray arrayWithArray:flows];
            weakSelf.loadedCount = weakSelf.activeFlows.count;
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
    else{
        //Going to user profile screen
        
    }
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
    [flow getFlowEvents:^(NSArray<Event*> * _Nullable events, NSError * _Nullable error) {
        if (error){
            NSLog(@"%@", error.localizedDescription);
        }
        else{
            //Delete all events in the array
            for (NSInteger i = 0; i < events.count; i++){
                [events[i] deleteInBackground];
            }
        }
    }];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //remove the deleted object from your data source.
        //If your data source is an NSMutableArray, do this
        Flow *removedFlow = self.activeFlows[indexPath.row];
        
        [self removeAssociatedEvents:removedFlow];
        [removedFlow deleteInBackground];
        
        [self.activeFlows removeObjectAtIndex:indexPath.row];
        [tableView reloadData]; // tell table to refresh now
    }
}

@end
