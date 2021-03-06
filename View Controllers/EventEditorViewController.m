//
//  EventEditorViewController.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/16/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "EventEditorViewController.h"
#import "FlowViewController.h"
#import "WeatherEditView.h"
#import "WeatherEditDelegate.h"
#import "NotificationUtils.h"

@interface EventEditorViewController () <UIPickerViewDelegate, UIPickerViewDataSource, WeatherEditViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endDatePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *DependsPickerView;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *condLabel;
@property (weak, nonatomic) IBOutlet UIButton *weatherButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (strong, nonatomic) NSArray<EventObject*> *filteredEvents;

@end

@implementation EventEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.startDatePicker.datePickerMode = UIDatePickerModeTime;
    self.endDatePicker.datePickerMode = UIDatePickerModeTime;
    
    self.DependsPickerView.delegate = self;
    self.DependsPickerView.dataSource = self;
    
    self.weatherButton.layer.cornerRadius = 5;
    self.saveButton.layer.cornerRadius = 5;
    
    if (self.eventObj){
        [self setupView];
    }
    else{
        self.eventObj = [EventObject new];
    }
    
    self.tempLabel.text = @"";
    self.condLabel.text = @"";
    
    NSLog(@"%@", self.eventObj);
    NSLog(@"%@", self.eventObjects);
    NSLog(@"%@", self.flow);
    
    //[self restrictDatePickers];
}

//Filter the events by which ones come before the starting date
- (void) filterEvents{
    self.filteredEvents = [self.eventObjects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        BOOL before = [self.startDatePicker.date compare:((EventObject*)evaluatedObject).startDate] == NSOrderedDescending;
        return before;
    }]];
}

- (NSInteger) getEventIndex: (EventObject*) evObj{
    for (long i = 0; i < self.eventObjects.count; i++){
        if ([self.eventObj compareEvent:self.eventObjects[i]]) return i;
    }
    return self.eventObjects.count;
}

- (void) startChanged{
    self.endDatePicker.minimumDate = self.startDatePicker.date;
    
    [self filterEvents];
    [self.DependsPickerView reloadAllComponents];
}

- (IBAction)startDateChanged:(id)sender {
    [self startChanged];
}

//NOTE: Not using this one right now, need a slightly more intitive way to write thiese notifs
- (void) setEnd: (id)sender{
    NSLog(@"Das ender isct das beginning");
    self.endDatePicker.minimumDate = self.startDatePicker.date;
}


- (void) restrictDatePickers{
    self.startDatePicker.minimumDate = self.flow.startDate;
    self.startDatePicker.maximumDate = self.flow.endDate;
    
    
    //[self.startDatePicker addTarget:self action:@selector(setEnd:) forControlEvents:UIControlEventValueChanged];
    
    self.endDatePicker.minimumDate = self.flow.startDate;
    self.endDatePicker.maximumDate = self.flow.endDate;
    
    
}

- (void) setupWeather{
    if (!self.weatherObj) return;
    self.tempLabel.text = [NSString stringWithFormat:@"%f", self.weatherObj.desiredTemp];
    self.condLabel.text = self.weatherObj.desiredCondition;
}


- (void) setupOperation: (EventObject*)eventObj{
    self.titleTextField.text = eventObj.title;
    [self.startDatePicker setDate:eventObj.startDate];
    [self.endDatePicker setDate:eventObj.endDate];
    
    NSInteger index = 0;
    if ([self.eventObj.dependsOn isKindOfClass:[EventObject class]]){
        NSLog(@"Auto-selecting stuff ");
        index = [self getEventIndex:(EventObject*)eventObj.dependsOn];
    }
    else if ([eventObj.dependsOn isKindOfClass:[WeatherObject class]]){
        self.weatherObj = (WeatherObject*)eventObj.dependsOn;
        [self setupWeather];
    }
    
    self.title = eventObj.title;
    
    [self filterEvents];
    [self.DependsPickerView reloadAllComponents];
    [self.DependsPickerView selectRow:index inComponent:0 animated:YES];
}
- (void) setupView{
    [self setupOperation:self.eventObj];
}


- (void) weatherOpen{
    WeatherEditView *weatherEView = [[WeatherEditView alloc] initWithFrame:CGRectZero];
       
       weatherEView.frame = CGRectMake(0, 0, self.view.superview.frame.size.width - 20, 450);
       weatherEView.center = self.view.center;
       
       //Make a background that covers the whole flowView
       UIView *touchInterceptView = [[UIView alloc] initWithFrame:CGRectZero];
       touchInterceptView.frame = self.view.superview.superview.bounds;
       touchInterceptView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
       touchInterceptView.center = weatherEView.center;
       
       WeatherObject *wObj = nil;
       if ([self.eventObj.dependsOn isKindOfClass:[WeatherObject class]])
           wObj = (WeatherObject*)self.eventObj.dependsOn;
       
       
       [self.view.superview addSubview:touchInterceptView];
       [self.view.superview bringSubviewToFront:touchInterceptView];
       
       //Bring the enlarged schedule view to the front
       [self.view.superview addSubview:weatherEView];
       [self.view.superview bringSubviewToFront:weatherEView];
       
       weatherEView.flow = self.flow;
       weatherEView.delegate = self;
       [weatherEView setupAssets:wObj eventObject:self.eventObj intercept:touchInterceptView];
}

- (IBAction)weatherButtonPressed:(id)sender {
    [self weatherOpen];
}

- (void) saveEdits: (EventObject*)eventObj{
    [eventObj saveToDatabase:self.flow completion:^(BOOL succeeded, NSError * _Nullable error) {
        //FlowViewController *fvc = (FlowViewController*)self.presentingViewController;
        
        UINavigationController *contrl = (UINavigationController*)self.presentingViewController;
        
        FlowViewController *fvc = [contrl viewControllers][1];
        
        [NotificationUtils removeNotification:eventObj]; //Remove the old notification and replace it with a new one
        [NotificationUtils loadNotification:eventObj];
        
        [fvc.objects addObject:eventObj];
        //Dismiss the editing view and update the Flow View
        
        [self dismissViewControllerAnimated:YES completion:^{
            //Question: Should this go in the initializeView section
            //Resets the englarged display view if it is currently being displayed
            if (fvc.currEnlargedView){
                [fvc.currEnlargedView setupDisplay:eventObj];
            }
            
            [fvc initializeView];
        }];
    }];
}

- (void) alertTitleCollision: (NSString*)title{
    NSString *messageStr = [NSString stringWithFormat:@"The title: %@ is already in use", title];
    UIAlertController *alert = [UIAlertController alloc];
    alert = [UIAlertController alertControllerWithTitle:@"Title Collision"
                                                message:messageStr
    preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Okay"
           style:UIAlertActionStyleDefault
       handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:okayAction];
    
    [self presentViewController:alert animated:YES completion:^{
        // optional code for what happens after the alert controller has finished presenting
    }];
}

- (void) saveOperation: (EventObject*)eventObj{
    eventObj.title = self.titleTextField.text;
    if ([Flow hasEventWithTitle:eventObj objects:self.eventObjects]){
        [self alertTitleCollision:self.titleTextField.text];
        return;
    }
        
    
    eventObj.startDate = self.startDatePicker.date;
    eventObj.endDate = self.endDatePicker.date;
    eventObj.userActive = YES;
    
    //Solving dependency issues
    NSInteger selectedRow = [self.DependsPickerView selectedRowInComponent:0];
    
    //Currently, a selected depends event takes precedence over a weather event
    //TODO: Show user an error when they try to tepend on more than one event (e.g.) the weather and another event
    if (selectedRow > 0){
        eventObj.dependsOn = self.eventObjects[selectedRow - 1];
        [self saveEdits:eventObj];
    }
    else if (self.weatherObj){
        [self.weatherObj saveToDatabase:self.flow completion:^(BOOL succeeded, NSError * _Nullable error) {
            eventObj.dependsOn = self.weatherObj;
            [self saveEdits: eventObj];
        }];
    }
    else{
        [self saveEdits: eventObj];
    }
    
    
}

- (IBAction)saveButtonPressed:(id)sender {
    [self saveOperation: self.eventObj];
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
    return self.filteredEvents.count + 1;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (row == 0) return @"None";
    else if (row <= self.filteredEvents.count)
        return self.filteredEvents[row - 1].title;
    return @"";
    //return [NSString stringWithFormat:@"Choice-%ld",(long)row];//Or, your suitable title; like Choice-a, etc.
}

- (void)pickerView:(UIPickerView *)thePickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
}

#pragma mark - Weather Edit View
- (void) weatherSaveButtonPressed:(WeatherEditView *)weatherView{
    //TODO: check over and remove magic numbers
    self.weatherObj = weatherView.weatherObj;
    [self setupWeather];
    //[self.eventObj loadAttributes];
    
    [self.DependsPickerView selectRow:0 inComponent:0 animated:YES];
}

- (void) weatherDeleteButtonPressed:(WeatherEditView *)weatherView{
    UIAlertController *alert = [UIAlertController alloc];
    
    alert = [UIAlertController alertControllerWithTitle:@"Delete weather"
         message:@"Are you sure that you want to delete this"
    preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes"
           style:UIAlertActionStyleDefault
       handler:^(UIAlertAction * _Nonnull action) {
        [self.weatherObj deleteDatabaseObj];
        self.weatherObj = nil;
        self.eventObj.dependsOn = nil;
        
        [self setupWeather];
    }];
    
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No"
           style:UIAlertActionStyleDefault
       handler:^(UIAlertAction * _Nonnull action) {
                   // handle response here.
    }];
    
    [alert addAction:yesAction];
    [alert addAction:noAction];
    
    [self presentViewController:alert animated:YES completion:^{
        // optional code for what happens after the alert controller has finished presenting
    }];
}
@end
