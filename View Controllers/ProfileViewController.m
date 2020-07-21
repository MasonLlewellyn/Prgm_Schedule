//
//  ProfileViewController.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/20/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "ProfileViewController.h"
#import "ImageUploadViewController.h"
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


@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupView];
}

- (void) setupView{
    //Facebook Login Test
    
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    // Optional: Place the button in the center of your view.
    loginButton.frame = self.connectFacebookButton.frame;//NOTE: This is a band-aid fix to get the Facebook login button oriented correctly
    [self.view addSubview:loginButton];
    self.connectFacebookButton.hidden = YES;
    
    User *currUser = [User currentUser];
    self.usernameLabel.text = currUser.username;
    
    if (currUser.profileImage){
        NSLog(@"Setting profile image because there is one");
        self.profilePictureView.file = currUser.profileImage;
        [self.profilePictureView loadInBackground];
    }
}

- (IBAction)connectToFacebookPressed:(id)sender {
    NSLog(@"You really press my buttons");
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
