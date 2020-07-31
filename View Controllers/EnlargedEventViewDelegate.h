//
//  EnlargedEventViewDelegate.h
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/17/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EnlargedEventView;
NS_ASSUME_NONNULL_BEGIN


@protocol EnlargedEventViewDelegate <NSObject>
- (void) displayDeleteAlert: (EnlargedEventView*)enlargedView;
- (void) editSelectedEvent: (EnlargedEventView*)enlargedView;
- (void) leavingEventView: (EnlargedEventView*)enlargedView;
//- (void) updateForChangedEvent: (EnlargedEventView*)enlargedEventView;//Update the cached dependencies for this changed event
@end

NS_ASSUME_NONNULL_END
