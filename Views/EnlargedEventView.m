//
//  EnlargedEventView.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/16/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "EnlargedEventView.h"

@implementation EnlargedEventView


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
    [[[NSBundle mainBundle] loadNibNamed:@"EnlargedEventView" owner:self options:nil] objectAtIndex:0];
    
    [self addSubview:self.contentView];
    self.contentView.frame = self.bounds;
}

- (void)leaveView{
    [self removeFromSuperview];
    
    [self.touchInterceptView removeFromSuperview];
    [self.delegate leavingEventView:self];
}

- (void)interceptTapped: (UITapGestureRecognizer*)recognizer{
    NSLog(@"Intercept tapped");
    [self leaveView];
}

- (IBAction)backButtonTapped:(id)sender {
    [self leaveView];
}

- (IBAction)deleteButtonTapped:(id)sender {
    [self.delegate displayDeleteAlert:self];
    [self leaveView];
}

- (IBAction)editButtonTapped:(id)sender {
    [self.delegate editSelectedEvent:self];
}
- (IBAction)activeSwitchValueChanged:(id)sender {
    UISwitch *switc = sender;
    self.eventObj.userActive = switc.isOn;
    NSLog(@"----I just flipped a switch: %d", self.eventObj.userActive);
    [self.eventObj updateSave:^(BOOL succeeded, NSError * _Nullable error) {
        if (error){
            NSLog(@"Enlarged view switch error: %@", error.localizedDescription);
        }
        else{
            //[self.delegate updateForChangedEvent:self];
        }
    }];
}

- (void)setupIntercept{
    NSLog(@"Setting up intercept");
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(interceptTapped:)];
    
    [self.touchInterceptView addGestureRecognizer: tapGestureRecognizer];
}


- (void) setupDisplay: (EventObject*)eventObj{
    self.eventObj = eventObj;
    
    self.titleLabel.text = eventObj.title;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
    formatter.timeStyle = NSDateFormatterShortStyle;
    
    self.startTimeLabel.text = [formatter stringFromDate:eventObj.startDate];
    self.endTimeLabel.text = [formatter stringFromDate:eventObj.endDate];
    
    self.contentView.layer.cornerRadius = 10;
    self.contentView.layer.masksToBounds = true;
    
    self.editButton.hidden = self.nonEditable;
    self.deleteButton.hidden = self.nonEditable;
    
    self.activeSwitch.on = self.eventObj.userActive;
}

- (void)setupAssets: (EventObject*)eventObj intercept: (UIView*)touchIntercept{
    [self setupDisplay:eventObj];
    self.touchInterceptView = touchIntercept;
    [self setupIntercept];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
