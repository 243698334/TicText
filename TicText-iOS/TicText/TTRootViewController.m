//
//  TTRootViewController.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/11/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTRootViewController.h"

@interface TTRootViewController () {
    BOOL _logInViewControllerPresented;
}

@end

@implementation TTRootViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // check user login status
    if (![PFUser currentUser]) {
        [self presentLogInViewControllerAnimated:NO];
        return;
    }
    
    // present ui
    // TODO
}

#pragma mark - TTRootViewController

- (void)presentLogInViewControllerAnimated:(BOOL)animated {
    if (_logInViewControllerPresented) {
        return;
    }
    
    _logInViewControllerPresented = YES;
    TTLogInViewController *logInViewController = [[TTLogInViewController alloc] init];
    logInViewController.delegate = self;
    [self presentViewController:logInViewController animated:animated completion:nil];
}

#pragma mark - TTLoginViewControllerDelegate

- (void)logInViewControllerDidLogUserIn:(TTLogInViewController *)logInViewController {
    NSLog(@"%@", logInViewController);
    if (_logInViewControllerPresented) {
        _logInViewControllerPresented = NO;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
