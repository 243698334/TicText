//
//  TTUtility.m
//  TicText
//
//  Created by Terrence K on 2/21/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTUtility.h"

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "TTUser.h"

@implementation TTUtility

+ (void)setupPushNotifications {
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

+ (BOOL)isParseServerReachable {
    Reachability *parseReachability = [Reachability reachabilityWithHostName:@"api.parse.com"];
    NetworkStatus parseNetworkStatus = [parseReachability currentReachabilityStatus];
    return parseNetworkStatus == ReachableViaWiFi || parseNetworkStatus == ReachableViaWWAN || [parseReachability connectionRequired];
}

@end
