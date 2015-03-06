//
//  TTSettings.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/25/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTSettings.h"

#define kNewTic @"newTic"
#define kExpireSoon @"expireSoon"
#define kRead @"read"

@implementation TTSettings


+ (void)changeNotificationPreferences:(BOOL)newTic expireSoon:(BOOL)expire read:(BOOL)read {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:newTic forKey:kNewTic];
    [userDefaults setBool:expire forKey:kExpireSoon];
    [userDefaults setBool:read forKey:kRead];
    [userDefaults synchronize];
}

+ (BOOL)getNewTicNotificationPreference {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kNewTic];
}

+ (BOOL)getExpireSoonNotificationPreference {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kExpireSoon];
}

+ (BOOL)getReadNotificationPreference {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kRead];
}

@end
