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

@property (strong, nonatomic) IBOutlet FBLoginView *facebookLogInView;
@property (nonatomic) BOOL presentForLogIn;

@end
