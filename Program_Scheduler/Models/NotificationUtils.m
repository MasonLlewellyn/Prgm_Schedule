//
//  NotificationUtils.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/30/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "NotificationUtils.h"
#import <UserNotifications/UserNotifications.h>

@implementation NotificationUtils


//TODO: Update this to take into account dependencies
+ (void) loadNotification:(EventObject *)eventObj{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *components = [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:eventObj.startDate];
    
    content.title = eventObj.title;
    content.sound = [UNNotificationSound defaultSound];
    UNCalendarNotificationTrigger *caltrig = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:eventObj.databaseObj.objectId content:content trigger:caltrig];
    
    
    [center addNotificationRequest:request withCompletionHandler:nil];
}

+ (void) removeNotification:(EventObject *)eventObj{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center removePendingNotificationRequestsWithIdentifiers:@[eventObj.databaseObj.objectId]];
}

+ (void) removeFlowNotifications:(Flow *)flow{
    [flow getFlowEvents:^(NSMutableArray<LocalDependsObject *> * _Nullable objects, NSError * _Nullable error) {
        if (error){
            NSLog(@"Network error with removing notifications");
        }
        else{
            for (unsigned long i = 0; i < objects.count; i++){
                if ([objects[i] isKindOfClass:[EventObject class]]){
                    [self removeNotification:(EventObject*)objects[i]];
                }
            }
        }
    }];
}

+ (void) loadFlowNotifications:(Flow *)flow{
    [flow evaluateObjects:^(NSMutableArray<LocalDependsObject *> * _Nullable objects, NSError * _Nullable error) {
        if (error){
            NSLog(@"Network error with removing notifications");
        }
        else{
            for (unsigned long i = 0; i < objects.count; i++){
                if ([objects[i] isKindOfClass:[EventObject class]]){
                    [self loadNotification:(EventObject*)objects[i]];
                }
            }
        }
    }];
}

@end
