//
//  ActionEditorViewController.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 8/7/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "ActionEditorViewController.h"
#import "FlowViewController.h"
#import "WeatherEditDelegate.h"
#import "NotificationUtils.h"

@interface ActionEditorViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *weatherButton;
@property (weak, nonatomic) IBOutlet UIButton *selectPlaylistButton;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *condLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endDatePicker;
@property (weak, nonatomic) IBOutlet UITextField *actionTitleTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *DependsPickerView;

@property (strong, nonatomic) NSArray<EventObject*> *filteredEvents;

@end

@implementation ActionEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.startDatePicker.datePickerMode = UIDatePickerModeTime;
    self.endDatePicker.datePickerMode = UIDatePickerModeTime;
    
    self.weatherButton.layer.cornerRadius = 5;
    self.saveButton.layer.cornerRadius = 5;
    self.selectPlaylistButton.layer.cornerRadius = 5;
    
    if (self.actionObj){
        [self setupView];
    }
    else{
        self.actionObj = [ActionObject new];
    }
    
    self.DependsPickerView.delegate = self;
    self.DependsPickerView.dataSource = self;
}

- (void) setupView{
    self.title = self.actionObj.title;
    
    self.startDatePicker.date = self.actionObj.startDate;
    self.endDatePicker.date = self.actionObj.endDate;
}

- (IBAction)startDateChanged:(id)sender {
    [super startChanged];
}

- (IBAction)weatherButtonPressed:(id)sender {
    [super weatherOpen];
}

- (IBAction)selectPlaylistPressed:(id)sender {
    
}
- (IBAction)saveButtonPressed:(id)sender {
    [super saveOperation];
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
