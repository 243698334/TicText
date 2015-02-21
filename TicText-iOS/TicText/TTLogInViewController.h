//
//  TTLogInViewController.h
//  TicText
//
//  Created by Kevin Yufei Chen on 2/7/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

// The view controller the user uses to log in.
@interface TTLogInViewController : UIViewController<FBLoginViewDelegate>

// FBLogInView is only used for the UI. FBsession is not used for the login process. 
@property (strong, nonatomic) IBOutlet FBLoginView *facebookLogInView;

@end
