//
//  EventObject.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/23/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "EventObject.h"

@implementation EventObject
- (BOOL)getActive{
    //If the event depends on something, evaluate that
    if (self.dependsOn){
        return [self.dependsOn getActive];
    }
    //If the event had no dependency, just let it be active
    return TRUE;
}
@end
