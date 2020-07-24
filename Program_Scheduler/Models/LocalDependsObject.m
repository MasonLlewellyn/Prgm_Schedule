//
//  LocalDependsObject.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/23/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "LocalDependsObject.h"

@implementation LocalDependsObject
- (BOOL) getActive{
    if (self.dependsOn){
        return [self.dependsOn getActive];
    }
    //Not active otherwise
    return NO;
}
- (void) saveToDatabase:(DependsObject *)DatabaseObject completionHandler:(PFBooleanResultBlock)completion{
    
}
@end
