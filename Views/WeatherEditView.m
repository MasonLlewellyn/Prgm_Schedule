//
//  WeatherEditView.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/28/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "WeatherEditView.h"


@implementation WeatherEditView 

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

- (void) leaveView{
    [self removeFromSuperview];
    [self.touchInterceptView removeFromSuperview];
}

- (void) interceptTapped: (UITapGestureRecognizer*)recognizer{
    //Leave the view if the intercept around the edit view is tapped
    NSLog(@"---Intercept tapped----");
    [self leaveView];
}

- (void) setupIntercept{
    NSLog(@"---Setting a faulty intercept----");
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(interceptTapped:)];
    
    tapGestureRecognizer.numberOfTapsRequired = 1;
    
    [self.touchInterceptView setUserInteractionEnabled:YES];
    [self.touchInterceptView addGestureRecognizer: tapGestureRecognizer];
}

- (void) customInit{
    [[[NSBundle mainBundle] loadNibNamed:@"WeatherEditView" owner:self options:nil] objectAtIndex:0];
    
    [self addSubview:self.contentView];
    self.contentView.frame = self.bounds;
}

- (void) setupAssets:(WeatherObject *)weatherObj eventObject:(nonnull EventObject *)eventObj intercept:(nonnull UIView *)touchIntercept{
    
    self.conditionStrings = @[@"Clear", @"Rain", @"Drizzle", @"Thunderstorm", @"Fog", @"Snow", @"Mist", @"Smoke", @"Haze", @"Dust", @"Sand", @"Ash", @"Squall", @"Tornado", @"Clouds"];
    
    self.conditionPickerView.dataSource = self;
    self.conditionPickerView.delegate = self;
    
    self.eventObj = eventObj;
    if (!weatherObj){
        //We are creating a new weather event
        self.weatherObj = [WeatherObject new];
    }
    
    self.contentView.layer.cornerRadius = 10;
    self.contentView.layer.masksToBounds = true;
    
    self.temperatureField.text = [NSString stringWithFormat:@"%f", weatherObj.desiredTemp];
    
    self.touchInterceptView = touchIntercept;
    [self setupIntercept];
}

- (IBAction)saveButtonPressed:(id)sender {
    self.weatherObj.desiredTemp = [self.temperatureField.text floatValue];
    self.weatherObj.desiredCondition = self.conditionStrings[[self.conditionPickerView selectedRowInComponent:0]];
    self.eventObj.dependsOn = self.weatherObj;
    [self leaveView];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - Picker View
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
     return 1;  // Or return whatever as you intend
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView
numberOfRowsInComponent:(NSInteger)component {
    return self.conditionStrings.count;//Or, return as suitable for you...normally we use array for dynamic
}

- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (row >= self.conditionStrings.count) return @"";
    return self.conditionStrings[row];
}

- (void)pickerView:(UIPickerView *)thePickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {

}
@end
