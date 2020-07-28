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
@property (strong, nonatomic) NSMutableArray<EventObject*> *eventObjects;
@end

@implementation FlowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initializeView];
    self.eventViews = [[NSMutableArray alloc] init];
}

#pragma mark - Event Space
//TODO: instantiate an EventView for each individual event and lay them out vertically
- (void) initializeView{
    //If the current user is looking at someone else's flow, they should not be able to edit it
    
    self.eventButton.hidden = self.nonEditable;
    self.actionButton.hidden = self.nonEditable;
    self.reminderButton.hidden = self.nonEditable;
    self.flowCopyButton.hidden = !self.nonEditable;
    
    [self destroyViews];
    
    [self.flow getFlowEvents:^(NSMutableArray<LocalDependsObject *> * _Nullable objects, NSError * _Nullable error) {
        if (error){
            
        }
        else{
            self.objects = objects;
            NSArray *interm = [self.objects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                return [evaluatedObject isKindOfClass:[EventObject class]];
            }]];
            
            self.eventObjects = [[NSMutableArray alloc] initWithArray:interm];
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

- (void) destroyViews{
    //TODO: cannot actually get views to disappear from the scroll View
    //Destroy all events that are on the current scrollview
    NSLog(@"!!!!!! Deleting %ld events !!!!!!!!!!!!!", self.eventViews.count);
    while (self.eventViews.count > 0){
        [self.eventViews[0] leaveView];
        [self.eventViews removeObjectAtIndex:0];
        NSLog(@"------Removing event-----");
    }
    NSLog(@"Event view counts %ld", self.eventViews.count);
}

- (void) makeEventViews{
    NSUInteger startY = 0;
    for (NSUInteger i = 0; i < self.eventObjects.count; i++){
        NSLog(@"Create New Obj");
        EventView *eView = [[EventView alloc] initWithFrame:CGRectMake(10, startY, 300, 120)];
        eView.nonEditable = self.nonEditable;
        
        [eView setupAssets:(EventObject*)(self.eventObjects[i]) flowViewController:self];
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
        evc.eventObjects = (NSArray*)[self.objects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [evaluatedObject isKindOfClass:[EventObject class]];
        }]];
        evc.flow = self.flow;
        
        
    }
}

#pragma mark - Enlarged Event View
    
- (NSInteger) getObjectIndex: (EventObject*) key{
    for (NSUInteger i = 0; i < self.objects.count; i++){
        if ((EventObject*)self.objects[i] == key)
            return i;
    }
    return self.objects.count;
}

- (NSUInteger) eventIndex: (EventObject*) key{
    for (NSUInteger i = 0; i < self.eventViews.count; i++){
        if ((EventObject*)self.eventViews[i].eventObj == key)
            return i;
    }
    return self.eventViews.count;
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
        //TODO: figure out why deleted views don't stay deleted
        [enlargedView.eventObj deleteDatabaseObj];
        //Refresh the Event space
        //[self initializeView];
        
        //NOTE: This gives a warning but you know what, it works
        //Also, it's pretty much guarunteed that the event is nonnll
        //NSUInteger eventIndex = [self.eventViews indexOfObject:enlargedView.eventObj];
        NSUInteger viewIndex = [self eventIndex:enlargedView.eventObj];
        NSLog(@"Remove index %lu", viewIndex);
        [self.eventViews removeObjectAtIndex:viewIndex];
        
        //TODO: for some reason it can't actually find where the eventObj is
        [self.eventObjects removeObjectAtIndex:viewIndex];
        
        NSLog(@"Event Views: %@", self.eventViews);
        NSLog(@"Objects: %@", self.eventObjects);
        
        [self destroyViews];
        //[self arrangeView];
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
    NSLog(@"%@", enlargedView.eventObj);
    [self performSegueWithIdentifier:@"flowToEventEditor" sender:enlargedView.eventObj];
}

- (void) leavingEventView:(EnlargedEventView *)enlargedView{
    [self initializeView];
    [self arrangeView];
}

@end
