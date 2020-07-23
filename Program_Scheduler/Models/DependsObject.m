//
//  DependsObject.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/23/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "DependsObject.h"

@implementation DependsObject
@dynamic dependsOn;
@dynamic flowID;

- (BOOL) getActive{
    return YES;
}
@end
