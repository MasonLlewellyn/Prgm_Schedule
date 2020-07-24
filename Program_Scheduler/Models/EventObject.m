//
//  EventObject.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/23/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "EventObject.h"

@implementation EventObject

@dynamic startDate;
@dynamic endDate;
@dynamic title;
@dynamic userBool;

+ (NSString*) getKind{
    return @"EventObj";
}

- (NSString*) getKind{
    return [EventObject getKind];
}

- (BOOL)getActive{
    //TODO: Implement me!
    return TRUE;
}
@end
