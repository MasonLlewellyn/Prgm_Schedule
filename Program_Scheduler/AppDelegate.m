//
//  AppDelegate.m
//  Program_Scheduler
//
//  Created by Mason Llewellyn on 7/13/20.
//  Copyright © 2020 Facebook University. All rights reserved.
//

#import "AppDelegate.h"
#import "User.h"
#import "playlistUtil.h"
#import "NotificationUtils.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Parse/Parse.h>
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


//Handles user notification when the application is in the foreground
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^) (UNNotificationPresentationOptions))completionHandler{
    
    UNNotificationPresentationOptions presentationOptions = UNNotificationPresentationOptionSound +UNNotificationPresentationOptionAlert;

    [center getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> * _Nonnull categories) {
        NSLog(@"OUTERMOST");
        for (UNNotificationCategory *i in categories){
            NSLog(@"BackChat!@!@#!");
            if ([i.identifier isEqualToString:@"ACTION_CATEGORY"]){
                NSLog(@"^###^@^!^#^$^@&#*(@&(#@&!^&@*FOUND it!: %@", i);
            }
        }
    }];
    
    [center getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
        for (UNNotification *notif in notifications){
            NSLog(@"%@", notif.request.content);
        }
    }];
    
    completionHandler(presentationOptions);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler{
    
   // response.notification.request.content
    if ([response.actionIdentifier isEqualToString:@"PLAY_ACTION"]){
        NSString *playlistID = response.notification.request.content.userInfo[@"PLAYLIST_ID"];
        NSLog(@"Playlist ID: %@", playlistID);
        [playlistUtil playIDPlaylist:playlistID];
    }
    
    completionHandler();
    
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [User registerSubclass]; //Hope this works
    ParseClientConfiguration *config = [ParseClientConfiguration   configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        
        configuration.applicationId = @"PROGRAM_SCHEDULE";
        configuration.server = @"http://program-schedule.herokuapp.com/parse";
    }];
    
    [Parse initializeWithConfiguration:config];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
