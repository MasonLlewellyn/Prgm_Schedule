//
//  FlowViewController.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/15/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "FlowViewController.h"
#import "FlowEditorViewController.h"
#import "EventEditorViewController.h"
#import "ActionEditorViewController.h"
#import "DependsObject.h"
#import "EventView.h"
#import "User.h"
#import "Weather.h"
#import "NotificationUtils.h"
#import "ActionObject.h"
#import <Parse/Parse.h>
#import <DGActivityIndicatorView/DGActivityIndicatorView.h>

@interface FlowViewController () <UNUserNotificationCenterDelegate, EventViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *eventButton;
@property (weak, nonatomic) IBOutlet UIButton *reminderButton;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIButton *flowCopyButton;
@property (weak, nonatomic) IBOutlet UIView *palleteView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *flowEditButton;


@property (strong, nonatomic) NSMutableArray<EventView*> *eventViews;
@property (strong, nonatomic) NSMutableArray<EventObject*> *eventObjects;
@property (nonatomic) DGActivityIndicatorView *activityIndicator;


@end

@implementation FlowViewController

const double heightPerMinute = 2.5; //TODO: update this with an actual acale value
const double emptyCoeff = 0.5;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.activityIndicator = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeNineDots tintColor:UIColor.redColor size:50.0f];
    self.activityIndicator.frame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
    self.activityIndicator.center = self.view.center;
    [self.view addSubview:self.activityIndicator];
    
    
    [self initializeView];
    self.eventViews = [[NSMutableArray alloc] init];
    
    self.title = self.flow.flowTitle;
    
    [self setupButtons];
    //[self loadNotifs];
}


- (void) setupButtons{
    self.palleteView.layer.cornerRadius = 8;
    self.eventButton.layer.cornerRadius = 5;
    self.reminderButton.layer.cornerRadius = 5;
    self.actionButton.layer.cornerRadius = 5;
    
    self.flowCopyButton.layer.cornerRadius = 5;
}

- (void) loadNotification: (EventObject*) eventObj{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *components = [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:eventObj.startDate];
    
    content.title = eventObj.title;
    content.sound = [UNNotificationSound defaultSound];
    
    UNCalendarNotificationTrigger *caltrig = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];
    
    //UNTimeIntervalNotificationTrigger *caltrig = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:10 repeats:NO];
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:eventObj.databaseObj.objectId content:content trigger:caltrig];
    
    [center addNotificationRequest:request withCompletionHandler:nil];
    
    
}


#pragma mark - Event Space
//TODO: instantiate an EventView for each individual event and lay them out vertically

- (void) sortEventList{
    //Sorts events by ascending
    NSArray<LocalDependsObject*> *sortedArr =  [self.objects sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [(NSDate*)obj1 compare:(NSDate*)obj2];
    }];
    
    
    self.objects = [[NSMutableArray alloc] initWithArray:sortedArr];
}



- (void) initializeView{
    //Start loading animation
    [self.activityIndicator startAnimating];
    
    //If the current user is looking at someone else's flow, they should not be able to edit it
    self.eventButton.hidden = self.nonEditable;
    self.actionButton.hidden = self.nonEditable;
    self.reminderButton.hidden = self.nonEditable;
    self.palleteView.hidden = self.nonEditable;
    
    if (self.nonEditable){
        [self.flowEditButton setEnabled:!self.nonEditable];
        [self.flowEditButton setTintColor:[UIColor clearColor]];
    }
    
    self.flowCopyButton.hidden = !self.nonEditable;
    
    [self destroyViews];
    
    [self.flow evaluateObjects:^(NSMutableArray<LocalDependsObject *> * _Nullable objects, NSError * _Nullable error) {
        if (error){
            
        }
        else{
            self.objects = objects;
            NSArray *interm = [self.objects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                return [evaluatedObject isKindOfClass:[EventObject class]];
                
            }]];
            
            self.eventObjects = [[NSMutableArray alloc] initWithArray:interm];
            [Weather initialize:^(NSError * _Nonnull error) {
                [self.activityIndicator stopAnimating];
                [self arrangeView];
            }];
        }
    }];
    
    
}

- (void) mismatchHandler: (LocalDependsObject*)localObj{
    //NOTE: event caches are updated before they are passed to the mismatch handler
    if ([localObj isKindOfClass:[EventObject class]]){
        if ([localObj getCached])
            [NotificationUtils loadNotification:(EventObject*)localObj];
        else
            [NotificationUtils removeNotification:(EventObject*)localObj];
    }
}

- (void) updateView{
    [self.flow updateEvaluations:self.objects mismatchHandler:^(LocalDependsObject * _Nonnull eventObj) {
        [self mismatchHandler:eventObj];
    }];
    
    NSArray *interm = [self.objects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject isKindOfClass:[EventObject class]];
    }]];
    self.eventObjects = [[NSMutableArray alloc] initWithArray:interm];
    
    [self destroyViews];
    [self arrangeView];
}


//Update the state of the event views if there is no re-rendering necessary
//This is in a situation where an event is not deleted or added but tather changed
- (void) updateEventViews{
    /*CGFloat contentHeight = (170) * (self.objects.count) - 20;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, contentHeight);*/
    
    for (unsigned long i = 0; i < self.eventViews.count; i++){
        [self.eventViews[i] setupAssets:self.eventObjects[i] flowViewController:self];
    }
}

- (void) eventsChanged{
    //The events should be re-evaluated and changed color based on their updated state, animate these changes
    
    [self.flow updateEvaluations:self.objects mismatchHandler:^(LocalDependsObject * _Nonnull eventObj) {
        UIColor *eventActiveColor = [UIColor colorWithRed:0.05 green:0.5 blue:0.5 alpha:1.0];
        UIColor *actionActiveColor = [UIColor colorWithRed:(39.0/255.0) green:(75.0/255.0) blue:(152.0/255.0) alpha:1.0];
        
        UIColor *activeColor = [eventObj isKindOfClass:[ActionObject class]] ? actionActiveColor : eventActiveColor;
        
        if ([eventObj isKindOfClass:[EventObject class]]){
            EventObject *evnt = (EventObject*)eventObj;
            [NotificationUtils removeNotification:(EventObject*)eventObj];
            NSUInteger viewIndex = [self eventIndex:evnt];
            
            [UIView animateWithDuration:0.2 animations:^{
                self.eventViews[viewIndex].contentView.backgroundColor = [eventObj getCached] ? activeColor : UIColor.redColor;
                
            }];
            
        }
        
       
        
    }];
}


- (void) sizeView{
    CGFloat contentHeight = 10; //Extra 10 for padding
    for (unsigned long i = 0; i < self.eventObjects.count; ++i){
        NSTimeInterval secondsBetween = [self.eventObjects[i].endDate timeIntervalSinceDate:self.eventObjects[i].startDate];
        
        contentHeight += (secondsBetween / 60) * heightPerMinute;
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, contentHeight);
    
}


- (void) arrangeView{
    /*CGFloat contentHeight = (170) * (self.objects.count) - 20;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, contentHeight);*/
    //[self sizeView];
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

- (CGFloat) secondsDifference: (NSDate*)startDate endDate:(NSDate*)endDate{
    unsigned int unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitMonth;

    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *diffComponents = [gregorian components:unitFlags fromDate:startDate toDate:endDate options:0];
    
    NSLog(@"Diff Hour: %ld", [diffComponents hour]);
    NSLog(@"Diff Minute: %ld", [diffComponents minute]);
    
    return 0.0;
}
- (void) makeEventViews{
    CGFloat startY = 0.0;
    
    CGRect contentRect = CGRectZero;
    
    for (NSUInteger i = 0; i < self.eventObjects.count; i++){
        NSLog(@"Create New Obj");
        
        NSTimeInterval secondsBetween = [self.eventObjects[i].endDate timeIntervalSinceDate:self.eventObjects[i].startDate];
        
        CGFloat viewHeight = (secondsBetween / 60) * heightPerMinute;
        
        //[self loadNotification:self.eventObjects[i]];
        EventView *eView = [[EventView alloc] initWithFrame:CGRectMake(10, startY, 300, viewHeight)];
        
        eView.nonEditable = self.nonEditable;
        eView.delegate = self;
        
        
        
        [eView setupAssets:(EventObject*)(self.eventObjects[i]) flowViewController:self];
        
        [self.scrollView addSubview:eView];
        [self.eventViews addObject:eView];
        
        contentRect = CGRectUnion(contentRect, eView.frame);
        
        
        if (i < self.eventObjects.count - 1){
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            
            NSDateComponents *nStartComp = [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:self.eventObjects[i+1].startDate];
            NSDateComponents *endComp = [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:self.eventObjects[i].endDate];
            
            NSDate *nDate = [gregorian dateFromComponents:nStartComp];
            NSDate *endDate = [gregorian dateFromComponents:endComp];
            
            NSTimeInterval interSeconds = [nDate timeIntervalSinceDate:endDate];
            
            CGFloat diffHeight = (interSeconds / 60) * emptyCoeff;
            
            //If two events overlap, make the later event lighter in opacity
            if (diffHeight < 0.0){
                eView.contentView.alpha = 0.75;
            }
            
            CGFloat totalSizeUp = viewHeight + diffHeight;
            startY += totalSizeUp;
            
            [self secondsDifference:self.eventObjects[i+1].startDate endDate: self.eventObjects[i].endDate];
        }
    }
    
    self.scrollView.contentSize = contentRect.size;
    
    
}
- (IBAction)flowEditButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"flowToFlowEditor" sender:self.flow];
}
- (IBAction)actionButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"flowToActionEditor" sender:nil];
}

- (IBAction)eventButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"flowToEventEditor" sender:nil];
}

- (IBAction)copyFlowButtonPressed:(id)sender {
    //Copy back the flow to the original user
    Flow *myFlow = [Flow new];
    
    myFlow.author = [User currentUser];
    [myFlow copyFlow:self.flow events:self.objects];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    
    self.view.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"timelineViewController"];
    
    //[myFlow saveInBackground];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[EventObject class]]|| sender == nil){
        //If we are editing an eventt or creating a new one
        NSLog(@"Segue to the editor view");
        UINavigationController *navCtrl = [segue destinationViewController];
        EventEditorViewController *evc = [navCtrl viewControllers][0];
        evc.eventObj = sender;
        
        if ([sender isKindOfClass:[ActionObject class]])
            ((ActionEditorViewController*)evc).actionObj = sender;
        
        evc.eventObjects = (NSArray*)[self.objects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            if (![evaluatedObject isKindOfClass:[EventObject class]]) return NO;
            
            BOOL sameEvent = (sender && [evaluatedObject compareEvent:sender]);
            
            
            /*if (sender)
            before = [((EventObject*)sender).startDate compare:((EventObject*)evaluatedObject).startDate] == NSOrderedDescending;*/
            
            return ([evaluatedObject isKindOfClass:[EventObject class]] && !sameEvent);
        }]];
        
        evc.flow = self.flow;
        
        
    }
    else if ([segue.identifier isEqualToString:@"flowToEventEditor"]){
        //UINavigationController *navCtrl = [segue destinationViewController];
        FlowEditorViewController *editCtrl = [segue destinationViewController];
        
        editCtrl.flow = self.flow;
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
    for (NSUInteger i = 0; i < self.eventObjects.count; i++){
        if (self.eventObjects[i] == key)
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
        
        NSArray<EventObject*>* children = [Flow getChildren:enlargedView.eventObj objects:self.eventObjects];
        
        for (unsigned long i = 0; i < children.count; i++){
            //reset the depends attribute of all of the children
            children[i].dependsOn = nil;
            [children[i] saveToDatabase:self.flow completion:^(BOOL succeeded, NSError * _Nullable error) {}];
        }
        
        
        [self destroyViews];
        
        NSUInteger viewIndex = [self eventIndex:enlargedView.eventObj];
        NSLog(@"Remove index %lu", viewIndex);
        //[self.eventViews removeObjectAtIndex:viewIndex];
        
        //TODO: for some reason it can't actually find where the eventObj is
        NSLog(@"%@", self.eventObjects[viewIndex]);
        [self.eventObjects removeObjectAtIndex:viewIndex];
        
        NSUInteger objIndex = [self getObjectIndex:enlargedView.eventObj];
        NSLog(@"%@", self.objects[viewIndex]);
        [self.objects removeObjectAtIndex:objIndex];
        
        
        //NSLog(@"Event Views: %@", self.eventViews);
        //NSLog(@"Objects: %@", self.eventObjects);
        
        NSLog(@"%lu", self.objects.count);
        NSLog(@"%lu", self.eventViews.count);
        [NotificationUtils removeNotification: enlargedView.eventObj];
        
        
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
    NSLog(@"%@", enlargedView.eventObj);
    
    NSString *segueID = [enlargedView.eventObj isKindOfClass:[ActionObject class]] ? @"flowToActionEditor" : @"flowToEventEditor";
    
    [self performSegueWithIdentifier:segueID sender:enlargedView.eventObj];
}

- (void) leavingEventView:(EnlargedEventView *)enlargedView{
    [self updateEventViews];
}

- (void) updateLeave: (EnlargedEventView*)enlargedView{
    [self updateView];
    [self arrangeView];
}


@end
