//
//  DependsObject.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/23/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "DependsObject.h"
#import "Flow.h"

@implementation DependsObject
@dynamic dependsOn;
@dynamic flowID;

+ (nonnull NSString *)parseClassName {
    return @"DependsObject";
}

- (BOOL) getActive{
    return YES;
}

- (void) saveToFlow:(Flow *)parentFlow completionHandler:(PFBooleanResultBlock)completion{
    self.flowID = parentFlow.objectId;
    if (completion == nil){
        [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {}];
    }
    else{
        [self saveInBackgroundWithBlock:completion];
    }
}
@end
