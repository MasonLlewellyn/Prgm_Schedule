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


+ (void) registerActions{
    NSLog(@"Registering actions!");
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNNotificationAction *playAction = [UNNotificationAction actionWithIdentifier:@"PLAY_ACTION" title:@"Play" options:UNNotificationActionOptionNone];
    
    UNNotificationCategory *actionCategory = [UNNotificationCategory categoryWithIdentifier:@"ACTION_CATEGORY" actions:@[playAction] intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];
    
    UNNotificationCategory *normalCategory = [UNNotificationCategory categoryWithIdentifier:@"NORMAL_CATEGORY" actions:@[] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
    
    [center setNotificationCategories:[[NSSet alloc] initWithArray:@[actionCategory, normalCategory]]];
}
+ (void) loadNotification:(EventObject *)eventObj{
    [NotificationUtils registerActions];
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *components = [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:eventObj.startDate];
    
    content.title = eventObj.title;
    content.sound = [UNNotificationSound defaultSound];
    
    if ([eventObj isKindOfClass:[ActionObject class]]){
        NSLog(@"Setting Notif with actions");
        content.categoryIdentifier = @"ACTION_CATEGORY";
        content.body = [NSString stringWithFormat:@"Playlist: %@", ((ActionObject*)eventObj).playlistTitle];
        //[content.userInfo setValue:((ActionObject*)eventObj).playlistID forKey:@"PLAYLIST_ID"];
        content.userInfo = @{@"PLAYLIST_ID": ((ActionObject*)eventObj).playlistID};
    }
    else{
        content.categoryIdentifier = @"NORMAL_CATEGORY";
        content.body = @"";
        content.userInfo = @{};
    }
    
    UNCalendarNotificationTrigger *caltrig = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];
    
    NSLog(@"Database ID: %@", eventObj.databaseObj.objectId);
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:eventObj.databaseObj.objectId content:content trigger:caltrig];
    
    
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {}];
    
    [center getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> * _Nonnull categories) {
        NSLog(@"OUTERMOST");
        for (UNNotificationCategory *i in categories){
            NSLog(@"BackChat!@!@#!");
            if ([i.identifier isEqualToString:@"ACTION_CATEGORY"]){
                NSLog(@"^###^@^!^#^$^@&#*(@&(#@&!^&@*FOUND it!: %@", i);
            }
        }
    }];
    
    [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
        NSLog(@"!!!!!!!!SYM-BIONIC Titan!!!!!!!");
        for (UNNotificationRequest *req in requests){
            if ([req.identifier isEqualToString:eventObj.databaseObj.objectId])
                NSLog(@"%@", req.content);
        }
    }];
    
    
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
