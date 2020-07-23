//
//  FlowViewController.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/15/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "FlowViewController.h"
#import "EventEditorViewController.h"
#import "EventView.h"
#import "User.h"
#import "Weather.h"
#import <Parse/Parse.h>


@interface FlowViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *eventButton;
@property (weak, nonatomic) IBOutlet UIButton *reminderButton;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIButton *flowCopyButton;


@property (strong, nonatomic) NSMutableArray<EventView*> *eventViews;
@end

@implementation FlowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initializeView];
}

#pragma mark - Event Space
//TODO: instantiate an EventView for each individual event and lay them out vertically
- (void) initializeView{
    //If the current user is looking at someone else's flow, they should not be able to edit it
    
    self.eventButton.hidden = self.nonEditable;
    self.actionButton.hidden = self.nonEditable;
    self.reminderButton.hidden = self.nonEditable;
    self.flowCopyButton.hidden = !self.nonEditable;
    
    [self.flow getFlowEvents:^(NSArray<Event*> * _Nullable objects, NSError * _Nullable error) {
        if (error){
            NSLog(@"%@", error.localizedDescription);
        }
        else{
            self.events = [NSMutableArray arrayWithArray:objects];
            [Weather getWeather:^(NSError *error, Weather *weather) {
                NSLog(@"Begin Completion");
                NSLog(@"------Weather Temp%f", weather.temperature);
                [self arrangeView];
            }];
            
        }
    }];
}

- (void) arrangeView{
    CGFloat contentHeight = (170) * (self.events.count) - 20;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, contentHeight);
    [self makeEventViews];
}

- (void) makeEventViews{
    NSUInteger startY = 0;
    for (NSUInteger i = 0; i < self.events.count; i++){
        EventView *eView = [[EventView alloc] initWithFrame:CGRectMake(10, startY, 300, 120)];
        eView.nonEditable = self.nonEditable;
        [eView setupAssets:self.events[i] flowViewController:self];
        
        [self.scrollView addSubview:eView];
        [self.eventViews addObject:eView];
        
        startY += 170;
    }
}

- (IBAction)eventButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"flowToEventEditor" sender:nil];
}
- (IBAction)copyFlowButtonPressed:(id)sender {
    //Copy back the flow to the original user
    Flow *myFlow = [Flow new];
    
    [myFlow copyFlow:self.flow events:self.events];
    myFlow.author = [User currentUser];
    [myFlow saveInBackground];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[Event class]] || sender == nil){
        //If we are editing an eventt or creating a new one
        UINavigationController *navCtrl = [segue destinationViewController];
        EventEditorViewController *evc = [navCtrl viewControllers][0];
        evc.event = sender;
        evc.flow = self.flow;
    }
}

#pragma mark - Enlarged Event View
- (void) displayDeleteAlert: (EnlargedEventView*)enlargedView{
    NSLog(@"Delegate Called!");
    UIAlertController *alert = [UIAlertController alloc];
    
    alert = [UIAlertController alertControllerWithTitle:@"Delete event"
         message:@"Are you sure that you want to delete this event"
    preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes"
           style:UIAlertActionStyleDefault
       handler:^(UIAlertAction * _Nonnull action) {
        [enlargedView.event deleteInBackground];
        //Refresh the Event space
        [self initializeView];
        
        //NOTE: This gives a warning but you know what, it works
        //Also, it's pretty much guarunteed that the event is nonnll
        NSUInteger eventIndex = [self.eventViews indexOfObject:enlargedView.event];
        [self.eventViews removeObjectAtIndex:eventIndex];
        [self arrangeView];
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

- (void) editSelectedEvent:(EnlargedEventView *)enlargedView{
    NSLog(@"Editing the selected event");
    [self performSegueWithIdentifier:@"flowToEventEditor" sender:enlargedView.event];
}


@end
