//
//  TTUtility.h
//  TicText
//
//  Created by Terrence K on 2/21/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

// An assortment of miscellaneous tools that are not big enough to merit their own class.
@interface TTUtility : NSObject

+ (void)setupPushNotifications;

+ (void)setupReachabilityMonitors;

+ (BOOL)isParseReachable;

+ (BOOL)isInternetReachable;

@end
