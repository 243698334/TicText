//
//  TTLogInViewController.h
//  TicText
//
//  Created by Kevin Yufei Chen on 2/7/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FacebookSDK/FacebookSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "TTConstants.h"

@protocol TTLogInViewControllerDelegate;

@interface TTLogInViewController : UIViewController <FBLoginViewDelegate>

@property (nonatomic, assign) id<TTLogInViewControllerDelegate> delegate;

@end

@protocol TTLogInViewControllerDelegate <NSObject>

- (void)logInViewControllerDidLogUserIn:(TTLogInViewController *)logInViewController;

@end