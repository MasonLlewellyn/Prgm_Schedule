//
//  SignUpViewController.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/13/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "SignUpViewController.h"
#import <Parse/Parse.h>

@interface SignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *rePasswordField;


@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.passwordField.secureTextEntry = YES;
    self.rePasswordField.secureTextEntry = YES;
}

- (IBAction)signUpPressed:(id)sender {
    [self registerUser];
}

- (bool)testFieldMatch{
    return [self.passwordField.text isEqual:self.rePasswordField.text];
}

- (BOOL) loginProtection{
    //A method to protect the login screen, returns good if both username and password are nonempty
    bool u_empty = [self.usernameField.text isEqual:@""];
    bool p_empty = [self.passwordField.text isEqual:@""];
    bool p_unmatch = ![self.passwordField.text isEqual:self.rePasswordField.text];
       
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
    
    else if (p_unmatch){
        alert = [UIAlertController alloc];
        alert = [UIAlertController alertControllerWithTitle:@"Login Error"
                message:@"Passwords must match"
           preferredStyle:(UIAlertControllerStyleAlert)];
               
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
               style:UIAlertActionStyleDefault
           handler:^(UIAlertAction * _Nonnull action) {
                       // handle response here.
        }];
               
        [alert addAction:okAction];
    }
    
    bool good_val = !((p_empty || u_empty) || p_unmatch);
    if (!good_val){
        [self presentViewController:alert animated:YES completion:^{
            // optional code for what happens after the alert controller has finished presenting
        }];
    }
    
    
    return good_val;
}

- (void)registerUser {
    bool good_pass = [self loginProtection];
    if (!good_pass) return;
    
    // initialize a user object
    PFUser *newUser = [PFUser user];
    
    // set user properties
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    
    // call sign up function on the object
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"User registered successfully");
            
            // manually segue to logged in view
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

@end
