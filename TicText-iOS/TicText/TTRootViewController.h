//
//  TTRootViewController.h
//  TicText
//
//  Created by Kevin Yufei Chen on 2/11/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <AFNetworking/AFNetworking.h>
#import "AppDelegate.h"
#import "TTLogInViewController.h"
#import "TTFindFriendsViewController.h"

@interface TTRootViewController : UIViewController <TTLogInViewControllerDelegate>

- (void)presentLogInViewControllerAnimated:(BOOL)animated;

@end
