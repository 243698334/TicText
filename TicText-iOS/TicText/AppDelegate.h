//
//  AppDelegate.h
//  TicText
//
//  Created by Kevin Yufei Chen on 1/27/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <ParseCrashReporting/ParseCrashReporting.h>
#import "TTConstants.h"
#import "TTSession.h"
#import "TTUser.h"
#import "TTTic.h"
#import "TTActivity.h"
#import "TTUserPrivateData.h"
#import "TTConversation.h"

#import "TTRootViewController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) UIWindow *window;

@end

