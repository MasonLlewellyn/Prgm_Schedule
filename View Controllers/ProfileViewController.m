//
//  ProfileViewController.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/20/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "ProfileViewController.h"
#import "ImageUploadViewController.h"
#import "User.h"
#import <Parse/Parse.h>
#import "SceneDelegate.h"
#import "LoginViewController.h"
#import "User.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
@import Parse;

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *connectFacebookButton;
@property (weak, nonatomic) IBOutlet PFImageView *profilePictureView;
@property (nonatomic) BOOL facebookLoggedIn;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupView];
}

- (void) setupView{
    //Facebook Login Test
    
    /*FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    // Optional: Place the button in the center of your view.
    loginButton.frame = self.connectFacebookButton.frame;//NOTE: This is a band-aid fix to get the Facebook login button oriented correctly
    [self.view addSubview:loginButton];*/
    
    UIColor *fbColor = [UIColor colorWithRed:59/255.0 green:89/255.0 blue:152/255.0 alpha:1.0];
    self.connectFacebookButton.backgroundColor = fbColor;
    
    User *currUser = [User currentUser];
    self.usernameLabel.text = currUser.username;
    
    if (currUser.profileImage){
        NSLog(@"Setting profile image because there is one");
        self.profilePictureView.file = currUser.profileImage;
        [self.profilePictureView loadInBackground];
    }
    
    if ([FBSDKAccessToken currentAccessToken]){
        NSLog(@"It's like talking to a brick wall");
        [self.connectFacebookButton setTitle:@"Log out of Facebook" forState:UIControlStateNormal];
        self.facebookLoggedIn = YES;
    }
}

- (void) updateUser{
    //Add facebook UserID to the current Parse User
    User *currUser = [User currentUser];
    NSLog(@"%@", currUser);
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
           if (!error) {
               NSLog(@"%@", result[@"id"]);
               currUser.facebooKID = result[@"id"];
               [currUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                   if (!error)
                       NSLog(@"Save was complete");
               }];
           }
       }];
}

- (void) loginFacebookUser: (FBSDKLoginManager*)loginManager{
    //Logs user in to Facebook
    [loginManager logInWithPermissions:@[@"user_friends"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult * _Nullable result, NSError * _Nullable error) {
        if (error){
            NSLog(@"Login error: %@", error.localizedDescription);
        }
        else{
            [self.connectFacebookButton setTitle:@"Log out of Facebook" forState:UIControlStateNormal];
            self.facebookLoggedIn = YES;
            [self updateUser];
        }
    }];
}
- (IBAction)connectToFacebookPressed:(id)sender {
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    if (self.facebookLoggedIn){
        NSLog(@"Logging you out.  Just because");
        [loginManager logOut];
        [self.connectFacebookButton setTitle:@"Connect to Facebook" forState:UIControlStateNormal];
        
        //Delete the facebook ID from the Parse database
        User *currUser = [User currentUser];
        currUser.facebooKID = nil;
        [currUser saveInBackground];
        
        self.facebookLoggedIn = NO;
    }
    else{
        NSLog(@"Maybe you can get in");
        [self loginFacebookUser: loginManager];
    }
    
}
- (IBAction)cameraButtonPressed:(id)sender {
    //Camera button used to add a profile picture to the user image
    [self performSegueWithIdentifier:@"profileToImageUploader" sender:nil];
}

- (IBAction)logoutPressed:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        sceneDelegate.window.rootViewController = loginViewController;
    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if (sender == nil){
        UINavigationController *navCtrl = [segue destinationViewController];
        ImageUploadViewController *ivc = [navCtrl viewControllers][0];
        ivc.profileView = self;
    }
}


@end
