//
//  ActionObject.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 8/7/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "ActionObject.h"

@implementation ActionObject

+ (NSString*) getKind{
    return @"ActionObj";
}

- (void) saveToDatabase:(Flow *)flow completion:(PFBooleanResultBlock)completion{
    DependsObject* dObj = [self pullDatabaseObj];
    dObj[@"playlistID"] = self.playlistID;
    dObj[@"playlistTitle"] = self.playlistTitle;
    
    [super saveToDatabase:flow completion:completion];
}
@end
