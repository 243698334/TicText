//
//  TTRootViewController.h
//  TicText
//
//  Created by Kevin Yufei Chen on 2/11/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

// The main view controller for this application.
@interface TTRootViewController : UIViewController

// Modally presents the login view controller, but only if the user is not logged in.
- (void)presentLogInViewControllerIfNeeded;

// Modally presents the login view controller.
- (void)presentLogInViewControllerForLogIn:(BOOL)logIn animated:(BOOL)animated;

// Logs the user out.
- (IBAction)logout:(id)sender;

@end
