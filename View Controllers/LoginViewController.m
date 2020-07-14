//
//  LoginViewController.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/13/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "LoginViewController.h"
#import "Parse.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)loginUser {
    NSString *username = @"";//self.usernameField.text;
    NSString *password = @"";//self.passwordField.text;
     
     [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
         if (error != nil) {
             NSLog(@"User log in failed: %@", error.localizedDescription);
         } else {
             NSLog(@"User logged in successfully");
             
             // display view controller that needs to shown after successful login
         }
     }];
 }
- (IBAction)loginButtonPressed:(id)sender {
    
}
- (IBAction)signUpPressed:(id)sender {
    [self performSegueWithIdentifier:@"loginToSignUp" sender:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
