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

@interface TimelineViewController ()
@property (nonatomic, strong) NSMutableArray *activeFlows;
@property (nonatomic, strong) NSMutableArray *inactiveFlows;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

NSString *HeaderViewIdentifier = @"TableViewHeaderView";

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:HeaderViewIdentifier];
    
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

- (void)fetchFlows{
    
    __weak typeof(self) weakSelf = self;
    PFQuery *actQuery = [Flow query];
    [actQuery whereKey:@"active" equalTo:[NSNumber numberWithBool:YES]];
    [actQuery findObjectsInBackgroundWithBlock:^(NSArray<Flow*> * _Nullable flows, NSError * _Nullable error) {
        if (flows){
            weakSelf.activeFlows = [NSMutableArray arrayWithArray:flows];
            NSLog(@"Active Count: %lu", weakSelf.activeFlows.count);
            
            [self.tableView reloadData];
        }
        else{
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
    PFQuery *inactQuery = [Flow query];
    [inactQuery whereKey:@"active" equalTo:[NSNumber numberWithBool:NO]];
    [inactQuery findObjectsInBackgroundWithBlock:^(NSArray<Flow*> * _Nullable flows, NSError * _Nullable error) {
        if (flows){
            weakSelf.inactiveFlows = [NSMutableArray arrayWithArray:flows];
            NSLog(@"Inactive Count: %lu", weakSelf.inactiveFlows.count);
            
            [self.tableView reloadData];
        }
        else{
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    if (section == 0){
        return self.activeFlows.count;
    }
    else{
        NSLog(@"returning inactive count");
        return self.inactiveFlows.count;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderViewIdentifier];
    NSLog(@"Posting up header");
    if (section == 0)
        header.textLabel.text = @"Active";
    else
        header.textLabel.text = @"Inactive";
    
    return header;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}


@end
