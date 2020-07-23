//
//  FriendsViewController.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/21/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "FriendsViewController.h"
#import "FriendsTableViewCell.h"
#import "User.h"
#import "TimelineViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface FriendsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *friendList;
@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.title = @"Friends";
    [self setupView];
}

- (void) setupView{
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    paramDict[@"fields"] = @"friends";
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends" parameters:nil]
      startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSLog(@"%@", result);
            self.friendList = result[@"data"];
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Table View
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
    //TODO: continue from here
    NSDictionary *userDict = self.friendList[indexPath.row];
    [cell setupCell: userDict];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friendList.count;
}

#pragma mark - Navigation

- (User*)getUserFromID: (NSString*)facebookID{
    PFQuery *query = [User query];
    [query whereKey:@"facebooKID" equalTo:facebookID];
    User *usr = [query getFirstObject];
    return usr;
}
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[FriendsTableViewCell class]]){
        //A tableviewcell was pressed meaning you should segue
        UINavigationController *navCtrl = [segue destinationViewController];
        TimelineViewController *timeline = [navCtrl viewControllers][0];
        
        FriendsTableViewCell *cell = sender;
        User *friendUser = [self getUserFromID: cell.userInfo[@"id"]];
        
        timeline.currUser = friendUser;
        timeline.showOther = YES;
    }
}


@end
