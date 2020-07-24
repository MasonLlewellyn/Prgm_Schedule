//
//  EventEditorViewController.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/16/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "EventEditorViewController.h"
#import "FlowViewController.h"

@interface EventEditorViewController ()
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endDatePicker;

@end

@implementation EventEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.startDatePicker.datePickerMode = UIDatePickerModeTime;
    self.endDatePicker.datePickerMode = UIDatePickerModeTime;
    
    if (self.eventObj)
        [self setupView];
}

- (void) setupView{
    self.titleTextField.text = self.eventObj.title;
    [self.startDatePicker setDate:self.eventObj.startDate];
    [self.endDatePicker setDate:self.eventObj.endDate];
}

- (IBAction)saveButtonPressed:(id)sender {
    if (self.eventObj == nil) self.eventObj = [EventObject new];
    
    self.eventObj.title = self.titleTextField.text;
    self.eventObj.startDate = self.startDatePicker.date;
    self.eventObj.endDate = self.endDatePicker.date;
    
    [self.eventObj saveToDatabase:self.flow completion:^(BOOL succeeded, NSError * _Nullable error) {
        FlowViewController *fvc = (FlowViewController*)self.presentingViewController;
        [fvc.objects addObject:self.eventObj];
        //Dismiss the editing view and update the Flow View
        [self dismissViewControllerAnimated:YES completion:^{
            //Question: Should this go in the initializeView section
            //Resets the englarged display view if it is currently being displayed
            if (fvc.currEnlargedView){
                [fvc.currEnlargedView setupDisplay:self.eventObj];
            }
            [fvc initializeView];
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
