//
//  AppDelegate.h
//  TicText
//
//  Created by Kevin Yufei Chen on 1/27/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <ParseCrashReporting/ParseCrashReporting.h>

#import "TTConstants.h"
#import "TTRootViewController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) UINavigationController *navigationController;

- (void)currentUserLogOut;

@end

