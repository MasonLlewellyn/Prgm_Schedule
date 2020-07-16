//
//  Flow.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/14/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "Flow.h"
#import "Event.h"

@implementation Flow

@dynamic flowTitle;
@dynamic author;
@dynamic events;
@dynamic active;
@dynamic startDate;
@dynamic endDate;

+ (nonnull NSString *)parseClassName {
    return @"Flow";
}

+ (void) testPostFlow{
    Flow *newFlow = [Flow new];
    newFlow.flowTitle = @"The other day";
    newFlow.startDate = [NSDate now];
    newFlow.endDate = [NSDate now];
    newFlow.active = NO;
    
    Event *newEvent = [Event dummyEvent];
    newEvent.Title = @"Fake event";
    Event *secondEvent = [Event dummyEvent];
    
    
    //NSLog(@"Pre objectID: %@", newFlow.objectId);
    [newFlow saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        //NSLog(@"Saved objectID: %@", newFlow.objectId);
        [newEvent saveEventToFlow:newFlow];
        [secondEvent saveEventToFlow:newFlow];
        
        for (int i = 0; i < 20; i++){
            Event *loopEvent = [Event dummyEvent];
            [loopEvent saveEventToFlow:newFlow];
        }
    }];
}

+ (void) testDownloadFlow{
    PFQuery *query = [Flow query];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray<Flow*> * _Nullable flows, NSError * _Nullable error) {
        if (flows){
            for (int i = 0; i < flows.count; i++){
                if ([flows[i].events[0] isKindOfClass:[Event class]])
                    NSLog(@"Its a real event");
                NSLog(@"%@: %@", flows[i].flowTitle, flows[i].events[0]);
            }
        }
        else{
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void) getFlowEvents: (PFQueryArrayResultBlock) completion {
    PFQuery *eventQuery = [Event query];
    [eventQuery whereKey:@"flowID" equalTo:self.objectId];
    [eventQuery findObjectsInBackgroundWithBlock:completion];
    
}



@end
