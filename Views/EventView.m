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
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    
    [self addGestureRecognizer:tapGestureRecognizer];
    tapGestureRecognizer.delegate = self;
}

- (void) viewTapped: (UITapGestureRecognizer*)recognizer{
    NSLog(@"You really just tapped my view...wow");
    [self presentEnlargedView];
}

- (void) presentEnlargedView{
    EnlargedEventView *bigEView = [[EnlargedEventView alloc] initWithFrame:CGRectZero];
    
    bigEView.frame = CGRectMake(0, 0, self.superview.superview.frame.size.width - 20, 300);
    bigEView.center = self.superview.superview.center;
    
    bigEView.delegate = self.flowVC;
    
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
    
    [bigEView setupAssets:self.event intercept:touchInterceptView];
}

- (void)setupAssets:(Event *)event flowViewController:(FlowViewController*)flowControl{
    self.event = event;
    self.titleLabel.text = event.Title;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
    //formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    
    self.startDateLabel.text = [formatter stringFromDate:event.startDateTime];
    
    
    self.contentView.layer.cornerRadius = 10;
    self.contentView.layer.masksToBounds = true;
    
    self.flowVC = flowControl;
    
    NSLog(@"%@", self.event);
    NSLog(@"%@", event.Title);
    NSLog(@"%@", self.titleLabel.text);
    
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
