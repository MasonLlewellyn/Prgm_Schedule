//
//  EventObject.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/23/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "EventObject.h"

@implementation EventObject

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

- (void) saveToDatabase:(Flow *)flow completion:(PFBooleanResultBlock)completion{
    DependsObject *dObj = [self pullDatabaseObj];
    dObj[@"title"] = self.title;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
    //formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    
    dObj[@"startDate"] = self.startDate;
    dObj[@"endDate"] = self.endDate;
    [super saveToDatabase:flow completion:completion];
}
@end
