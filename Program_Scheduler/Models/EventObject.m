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

/*- (BOOL)getActive{
    //TODO: Implement me!
    return TRUE;
}*/

- (BOOL) compareEvent:(EventObject *)otherEvent{
    BOOL stringCmp = [self.title isEqualToString:otherEvent.title];
    BOOL startComp = [self.startDate isEqual:otherEvent.startDate];
    BOOL endComp = [self.endDate isEqual:otherEvent.endDate];
    return (stringCmp && startComp && endComp);
}

- (void) loadAttributes{
    [super loadAttributes];
    
    self.databaseObj[@"title"] = self.title;
    self.databaseObj[@"startDate"] = self.startDate;
    self.databaseObj[@"endDate"] = self.endDate;
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

- (instancetype) copy{
    EventObject *newObj = [EventObject new];
    
    newObj.title = [self.title copy];
    newObj.startDate = self.startDate;
    newObj.endDate = self.endDate;
    newObj.userBool = self.userBool;
    
    return newObj;
}
@end
