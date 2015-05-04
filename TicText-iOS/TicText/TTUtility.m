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

static Reachability *internetReachability = nil;
static Reachability *parseReachability = nil;

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

+ (void)setupReachabilityMonitors {
    internetReachability = [Reachability reachabilityForInternetConnection];
    parseReachability = [Reachability reachabilityWithHostName:@"api.parse.com"];
    [internetReachability startNotifier];
}

+ (BOOL)isParseReachable {
    if (parseReachability == nil) {
        [self setupReachabilityMonitors];
    }
    NetworkStatus parseReachabilityStatus = [parseReachability currentReachabilityStatus];
    return parseReachabilityStatus == ReachableViaWiFi || parseReachabilityStatus == ReachableViaWWAN || [parseReachability connectionRequired];
}

+ (BOOL)isInternetReachable {
    if (internetReachability == nil) {
        [self setupReachabilityMonitors];
    }
    NetworkStatus internetReachabilityStatus = [internetReachability currentReachabilityStatus];
    return internetReachabilityStatus == ReachableViaWiFi || internetReachabilityStatus == ReachableViaWWAN;
}

@end
