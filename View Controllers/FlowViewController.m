//
//  FlowViewController.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/15/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "FlowViewController.h"
#import "EventEditorViewController.h"
#import "DependsObject.h"
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
    
    
    [self.flow getFlowEvents:^(NSMutableArray<LocalDependsObject *> * _Nullable objects, NSError * _Nullable error) {
        if (error){
            
        }
        else{
            NSLog(@"------------Local Objects: %@", objects);
            self.objects = objects;
            [Weather initialize:^(NSError * _Nonnull error) {
                [self arrangeView];
            }];
        }
        
    }];
}

- (void) arrangeView{
    CGFloat contentHeight = (170) * (self.objects.count) - 20;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, contentHeight);
    [self makeEventViews];
}



- (void) makeEventViews{
    NSUInteger startY = 0;
    for (NSUInteger i = 0; i < self.objects.count; i++){
        if (![[self.objects[i] getKind] isEqualToString:[EventObject getKind]]) continue;
        
        EventView *eView = [[EventView alloc] initWithFrame:CGRectMake(10, startY, 300, 120)];
        eView.nonEditable = self.nonEditable;
        
        [eView setupAssets:(EventObject*)(self.objects[i]) flowViewController:self];
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
    
    //[myFlow copyFlow:self.flow events:self.events];
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
        evc.eventObj = sender;
        evc.flow = self.flow;
    }
}

#pragma mark - Enlarged Event View
- (NSUInteger) eventIndex: (EventObject*) key{
    for (NSUInteger i = 0; i < self.eventViews.count; i++){
        if ((EventObject*)self.eventViews[i].eventObj == key)
            return i;
    }
    return self.objects.count;
}
- (void) displayDeleteAlert: (EnlargedEventView*)enlargedView{
    NSLog(@"Delegate Called!");
    UIAlertController *alert = [UIAlertController alloc];
    
    alert = [UIAlertController alertControllerWithTitle:@"Delete event"
         message:@"Are you sure that you want to delete this event"
    preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes"
           style:UIAlertActionStyleDefault
       handler:^(UIAlertAction * _Nonnull action) {
        [enlargedView.eventObj deleteDatabaseObj];
        //Refresh the Event space
        [self initializeView];
        
        //NOTE: This gives a warning but you know what, it works
        //Also, it's pretty much guarunteed that the event is nonnll
        //NSUInteger eventIndex = [self.eventViews indexOfObject:enlargedView.eventObj];
        NSUInteger eventIndex = [self eventIndex:enlargedView.eventObj];
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
    [self performSegueWithIdentifier:@"flowToEventEditor" sender:enlargedView.eventObj];
}


@end
