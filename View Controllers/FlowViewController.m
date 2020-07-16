//
//  FlowViewController.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/15/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "FlowViewController.h"
#import "EventView.h"
#import <Parse/Parse.h>

@interface FlowViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation FlowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initializeView];
}

//TODO: instantiate an EventView for each individual event and lay them out vertically
- (void) initializeView{
    [self.flow getFlowEvents:^(NSArray<Event*> * _Nullable objects, NSError * _Nullable error) {
        if (error){
            NSLog(@"%@", error.localizedDescription);
        }
        else{
            self.events = [NSMutableArray arrayWithArray:objects];
            [self arrangeView];
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
        
        [eView setupAssets:self.events[i]];
        
        [self.scrollView addSubview:eView];
        
        startY += 170;
    }
    //[eView release];
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
