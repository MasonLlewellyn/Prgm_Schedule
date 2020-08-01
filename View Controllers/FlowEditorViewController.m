//
//  FlowEditorViewController.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/27/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "FlowEditorViewController.h"
#import <Parse/Parse.h>
#import "User.h"

@interface FlowEditorViewController ()
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endDatePicker;
@property (weak, nonatomic) IBOutlet UISwitch *activationSwitch;

@end

@implementation FlowEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.flow){
        [self setViewFromFlow];
    }
    else {
        self.flow = [Flow new];
    }
    // Do any additional setup after loading the view.
}

- (void) setViewFromFlow{
    self.titleTextField.text = self.flow.flowTitle;
    
    if (self.flow.startDate)
        self.startDatePicker.date = self.flow.startDate;
    if (self.flow.endDate)
        self.endDatePicker.date = self.flow.endDate;
    
    self.activationSwitch.on = self.flow.active;
}

- (IBAction)saveButtonPressed:(id)sender {
    self.flow.flowTitle = self.titleTextField.text;
    self.flow.startDate = self.startDatePicker.date;
    self.flow.endDate = self.endDatePicker.date;
    self.flow.active = self.activationSwitch.isOn;
    self.flow.author = [User currentUser];
    
    [self.flow saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        //[self performSegueWithIdentifier:@"EditorToFlow" sender:self.flow];
        
        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate editFlowSaved:self];
        }];
        
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
