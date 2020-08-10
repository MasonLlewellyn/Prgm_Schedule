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
#import "PlaylistSelectView.h"
#import "playlistUtil.h"

@interface ActionEditorViewController () <UIPickerViewDataSource, UIPickerViewDelegate, PlaylistSelectViewDelegate>
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
        NSLog(@"%@", self.actionObj.playlistTitle);
    }
    else{
        self.actionObj = [ActionObject new];
    }
    
    self.DependsPickerView.delegate = self;
    self.DependsPickerView.dataSource = self;
}

- (void) setupView{
    [super setupOperation:self.actionObj];
    [self.selectPlaylistButton setTitle:self.actionObj.playlistTitle forState:UIControlStateNormal];
    
    
}

- (IBAction)startDateChanged:(id)sender {
    [super startChanged];
}

- (IBAction)weatherButtonPressed:(id)sender {
    [super weatherOpen];
}

- (IBAction)selectPlaylistPressed:(id)sender {
    PlaylistSelectView *psView = [[PlaylistSelectView alloc] initWithFrame:CGRectZero];
    psView.frame = CGRectMake(0, 0, self.view.superview.frame.size.width - 20, 450);
    psView.center = self.view.center;
    
    //Make a background that covers the whole flowView
    UIView *touchInterceptView = [[UIView alloc] initWithFrame:CGRectZero];
    touchInterceptView.frame = self.view.superview.superview.bounds;
    touchInterceptView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
    touchInterceptView.center = psView.center;
    
    [self.view.superview addSubview:touchInterceptView];
    [self.view.superview bringSubviewToFront:touchInterceptView];
    
    [self.view.superview addSubview:psView];
    [self.view.superview bringSubviewToFront:psView];
    
    psView.delegate = self;
    [psView setupAssets:self.actionObj touchIntercept:touchInterceptView];
}

- (IBAction)saveButtonPressed:(id)sender {
    [super saveOperation: self.actionObj];
}

#pragma mark Playlist Select View
- (void) playlistSelected:(MPMediaItemCollection *)selectedPlaylist{
    self.actionObj.playlistID = [selectedPlaylist valueForProperty:MPMediaPlaylistPropertyPersistentID];
    self.actionObj.playlistTitle = [selectedPlaylist valueForProperty:MPMediaPlaylistPropertyName];
    
    
    self.selectPlaylistButton.titleLabel.text = self.actionObj.playlistTitle;
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
