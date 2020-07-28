//
//  EventEditorViewController.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/16/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "EventEditorViewController.h"
#import "FlowViewController.h"

@interface EventEditorViewController () <UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endDatePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *DependsPickerView;

@end

@implementation EventEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.startDatePicker.datePickerMode = UIDatePickerModeTime;
    self.endDatePicker.datePickerMode = UIDatePickerModeTime;
    
    if (self.eventObj)
        [self setupView];
    
    self.DependsPickerView.delegate = self;
    self.DependsPickerView.dataSource = self;
    
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
    self.eventObj.dependsOn = self.eventObjects[[self.DependsPickerView selectedRowInComponent:0]];
    
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

#pragma mark - Picker View
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
     return 1;  // Or return whatever as you intend
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView
numberOfRowsInComponent:(NSInteger)component {
     return 3;//Or, return as suitable for you...normally we use array for dynamic
}

- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (row < self.eventObjects.count)
        return self.eventObjects[row].title;
    return @"";
    //return [NSString stringWithFormat:@"Choice-%ld",(long)row];//Or, your suitable title; like Choice-a, etc.
}

- (void)pickerView:(UIPickerView *)thePickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {

}
@end
