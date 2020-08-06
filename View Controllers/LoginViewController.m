//
//  LoginViewController.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/13/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>


@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.passwordField.secureTextEntry = YES;
    
    self.signUpButton.layer.cornerRadius = 5;
    self.loginButton.layer.cornerRadius = 5;
    
}

- (BOOL) loginProtection{
    //A method to protect the login screen, returns good if both username and password are nonempty
    bool u_empty = [self.usernameField.text isEqual:@""];
    bool p_empty = [self.passwordField.text isEqual:@""];
       
    UIAlertController *alert = [UIAlertController alloc];
    if (u_empty && p_empty){
        alert = [UIAlertController alertControllerWithTitle:@"Login Error"
                message:@"Both Username and Password cannot be empty"
           preferredStyle:(UIAlertControllerStyleAlert)];
               
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
               style:UIAlertActionStyleDefault
           handler:^(UIAlertAction * _Nonnull action) {
                       // handle response here.
        }];
               
        [alert addAction:okAction];
           
    }
    else if (u_empty){
        alert = [UIAlertController alertControllerWithTitle:@"Login Error"
                message:@"Username cannot be empty"
        preferredStyle:(UIAlertControllerStyleAlert)];
               
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
               style:UIAlertActionStyleDefault
        handler:^(UIAlertAction * _Nonnull action) {
                       // handle response here.
        }];
               
        [alert addAction:okAction];
               
    }
    else if (p_empty){
        alert = [UIAlertController alertControllerWithTitle:@"Login Error"
            message:@"Password cannot be empty"
            preferredStyle:(UIAlertControllerStyleAlert)];
               
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
                           // handle response here.
                       }];
               
        [alert addAction:okAction];
    }
    
    bool good_val = !(p_empty || u_empty);
    if (!good_val){
        [self presentViewController:alert animated:YES completion:^{
            // optional code for what happens after the alert controller has finished presenting
        }];
    }
    
    
    return good_val;
}

- (void)loginUser {
    if (![self loginProtection]) return;
    
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
         if (error != nil) {
             NSLog(@"User log in failed: %@", error.localizedDescription);
         } else {
             NSLog(@"User logged in successfully");
             // display view controller that needs to shown after successful login
              UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
             
             
             self.view.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"timelineViewController"];
             //[self performSegueWithIdentifier:@"loginToTimeline" sender:nil];
         }
     }];
 }

- (IBAction)loginButtonPressed:(id)sender {
    [self loginUser];
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
