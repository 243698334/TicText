//
//  TTSettings.h
//  TicText
//
//  Created by Kevin Yufei Chen on 2/25/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTSettings : NSObject
+ (void)changeNotificationPreferences:(BOOL)newTic expireSoon:(BOOL)expire read:(BOOL)read;
+ (BOOL)newTicNotificationPreference;
+ (BOOL)expireSoonNotificationPreference;
+ (BOOL)readNotificationPreference;
@end
