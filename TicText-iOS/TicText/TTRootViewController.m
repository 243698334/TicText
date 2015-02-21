//
//  TTRootViewController.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/11/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTRootViewController.h"

#import "TTLogInViewController.h"
#import "TTFindFriendsViewController.h"

#import "TTSession.h"

@implementation TTRootViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kTTUIPurpleColor;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self presentLogInViewControllerIfNeeded];
}

- (IBAction)logout:(id)sender {
    [TTSession.sharedSession logout:^{
        [self presentLogInViewControllerForLogIn:NO animated:YES];
    }];
}

#pragma mark - TTRootViewController

- (void)presentLogInViewControllerIfNeeded {
    if (![TTSession.sharedSession isUserLoggedIn]) {
        [self presentLogInViewControllerForLogIn:YES animated:NO];
    }
}

// @remark - why do we need the presentForLogIn flag?
- (void)presentLogInViewControllerForLogIn:(BOOL)presentForLogIn animated:(BOOL)animated {
    UIViewController *loginViewController = [[TTLogInViewController alloc] init];
    ((TTLogInViewController *)loginViewController).presentForLogIn = presentForLogIn;
    [self presentViewController:loginViewController animated:animated completion:nil];
}

@end
