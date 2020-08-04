//
//  EventView.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/15/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "EventView.h"
#import "EnlargedEventView.h"


@implementation EventView


- (instancetype) initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    
    if (self){
        if (self.subviews.count == 0){
            [self customInit];
        }
        
    }
    
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self){
        if (self.subviews.count == 0)
            [self customInit];
    }
    
    return self;
}

- (void) customInit{
    [[[NSBundle mainBundle] loadNibNamed:@"EventView" owner:self options:nil] objectAtIndex:0];
    
    [self addSubview:self.contentView];
    self.contentView.frame = self.bounds;
    
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    
    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    
    [self addGestureRecognizer:singleTapRecognizer];
    [self addGestureRecognizer:doubleTapRecognizer];
    
    doubleTapRecognizer.delegate = self;
    singleTapRecognizer.delegate = self;
}


- (void) viewDoubleTapped: (UITapGestureRecognizer*)recognizer{
    NSLog(@"------Double tapped------");
    self.eventObj.userActive = !self.eventObj.userActive;
    //NSLog(@"----I just flipped a switch: %d", self.eventObj.userActive);
    
    [self.eventObj updateSave:^(BOOL succeeded, NSError * _Nullable error) {
        if (error){
            NSLog(@"Doubletap Switch error: %@", error.localizedDescription);
        }
        else{
            //[self.delegate updateForChangedEvent:self];
            [self.delegate eventsChanged];
        }
    }];
}

- (void) viewTapped: (UITapGestureRecognizer*)recognizer{
    NSLog(@"You really just tapped my view...wow");
    [self presentEnlargedView];
}

- (void) presentEnlargedView{
    EnlargedEventView *bigEView = [[EnlargedEventView alloc] initWithFrame:CGRectZero];
    bigEView.nonEditable = self.nonEditable;
    
    bigEView.frame = CGRectMake(0, 0, self.superview.superview.frame.size.width - 20, 0);
    bigEView.center = self.superview.superview.center;
    
    bigEView.delegate = self.flowVC;
    
    [UIView animateWithDuration:0.2 animations:^{
        bigEView.frame = CGRectMake(0, 0, self.superview.superview.frame.size.width - 20, 300);
        bigEView.center = self.superview.superview.center;
    }];
    
    self.flowVC.currEnlargedView = bigEView;
    
    //Make a background that covers the whole flowView
    UIView *touchInterceptView = [[UIView alloc] initWithFrame:CGRectZero];
    touchInterceptView.frame = self.superview.superview.bounds;
    touchInterceptView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
    touchInterceptView.center = bigEView.center;
    
    [self.superview.superview addSubview:touchInterceptView];
    [self.superview.superview bringSubviewToFront:touchInterceptView];
    
    //Bring the enlarged schedule view to the front
    [self.superview.superview addSubview:bigEView];
    [self.superview.superview bringSubviewToFront:bigEView];
    
    [bigEView setupAssets:self.eventObj intercept:touchInterceptView];
}

- (void)setupAssets:(EventObject *)eventObj flowViewController:(FlowViewController*)flowControl{
    self.eventObj = eventObj;
    self.titleLabel.text = eventObj.title;
    
    UIColor *activeColor = [UIColor colorWithRed:0.05 green:0.5 blue:0.5 alpha:1.0];
    self.contentView.backgroundColor = [self.eventObj getCached] ?  activeColor: UIColor.redColor;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
    //formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    
    self.startDateLabel.text = [formatter stringFromDate:eventObj.startDate];
    
    
    self.contentView.layer.cornerRadius = 10;
    self.contentView.layer.masksToBounds = true;
    
    self.flowVC = flowControl;
    
}

- (void) leaveView{
    [self.contentView removeFromSuperview];
    [self removeFromSuperview];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
