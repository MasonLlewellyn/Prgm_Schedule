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

@interface TimelineViewController ()
@property (nonatomic, strong) NSMutableArray *activeFlows;
@property (nonatomic, strong) NSMutableArray *inactiveFlows;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) BOOL isMoreDataLoading;
@property (assign, nonatomic) NSInteger loadedCount;
@end

//NSString *HeaderViewIdentifier = @"TableViewHeaderView";
NSInteger pageCount = 5;

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    //[self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:HeaderViewIdentifier];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshFlows:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:refreshControl atIndex:0];
    
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

- (void)fetchFlows{
    
    __weak typeof(self) weakSelf = self;
    PFQuery *query = [Flow query];
    query.limit = pageCount;
    //[actQuery whereKey:@"active" equalTo:[NSNumber numberWithBool:YES]];
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
    __weak typeof(self) weakSelf = self;
    PFQuery *query = [Flow query];
    query.skip = self.loadedCount;
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
    if (sender){
        FlowFeedTableViewCell *cell = sender;
        FlowViewController *controller = [segue destinationViewController];
        
        controller.flow = cell.flow;
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

@end
