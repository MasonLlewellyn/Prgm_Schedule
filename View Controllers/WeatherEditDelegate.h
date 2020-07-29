//
//  WeatherEditDelegate.h
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/29/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import <Foundation/Foundation.h>

/*#ifndef WeatherEditDelegate_h
#define WeatherEditDelegate_h*/

@class WeatherEditView;
NS_ASSUME_NONNULL_BEGIN

@protocol WeatherEditViewDelegate <NSObject>
- (void) weatherSaveButtonPressed: (WeatherEditView*)weatherView;
@end

NS_ASSUME_NONNULL_END
//#endif /* WeatherEditDelegate_h */
