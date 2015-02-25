//
//  TTRootViewController.h
//  TicText
//
//  Created by Kevin Yufei Chen on 2/11/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MBProgressHUD/MBProgressHUD.h>

#import "AppDelegate.h"
#import "TTConstants.h"
#import "TTSession.h"
#import "TTUtility.h"

// The main view controller for this application.
@interface TTRootViewController : UIViewController

// Modally presents the login view controller, but only if the user is not logged in.
- (void)presentLogInViewControllerIfNeeded;

// Modally presents the login view controller.
- (void)presentLogInViewControllerAnimated:(BOOL)animated;

@end
