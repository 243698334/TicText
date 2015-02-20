//
//  TTRootViewController.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/11/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTRootViewController.h"

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
        [self presentLogInViewController:YES];
    }];
}

#pragma mark - TTRootViewController

- (void)presentLogInViewControllerIfNeeded {
    if (![TTSession.sharedSession isUserLoggedIn]) {
        [self presentLogInViewController:NO];
    }
}

- (void)presentLogInViewController:(BOOL)animated {
    UIViewController *loginViewController = [[TTLogInViewController alloc] init];
    
    [self presentViewController:loginViewController animated:animated completion:nil];
}

- (void)setupPushNotification {
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}


@end
