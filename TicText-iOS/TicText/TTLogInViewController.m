//
//  TTLogInViewController.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/7/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTLogInViewController.h"

@interface TTLogInViewController () {
    FBLoginView *_facebookLogInView;
}

@property (nonatomic, strong) MBProgressHUD *progressHUD;

@end

@interface FBSession (Private)

- (void)clearAffinitizedThread;

@end

@implementation TTLogInViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Facebook Log In View
    CGFloat facebookLogInViewWidth = self.view.bounds.size.width * 0.75;
    CGFloat facebookLogInViewHeight = 44.0;
    CGFloat facebookLogInViewOriginX = (self.view.bounds.size.width - facebookLogInViewWidth) / 2;
    CGFloat facebookLogInViewOriginY = self.view.frame.size.height * 0.8;
    _facebookLogInView = [[FBLoginView alloc] initWithReadPermissions:@[@"public_profile", @"user_friends", @"email", @"user_photos"]];
    _facebookLogInView.frame = CGRectMake(facebookLogInViewOriginX, facebookLogInViewOriginY, facebookLogInViewWidth, facebookLogInViewHeight);
    _facebookLogInView.delegate = self;
    _facebookLogInView.tooltipBehavior = FBLoginViewTooltipBehaviorDisable;
    [self.view addSubview:_facebookLogInView];

}


#pragma mark - FBLoginViewDelegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    if ([PFUser currentUser]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(logInViewControllerDidLogUserIn:)]) {
            [self.delegate performSelector:@selector(logInViewControllerDidLogUserIn:) withObject:[PFUser currentUser]];
        }
        return;
    }
    
    NSString *accessToken = [[[FBSession activeSession] accessTokenData] accessToken];
    NSDate *expirationDate = [[[FBSession activeSession] accessTokenData] expirationDate];
    NSString *facebookID = [[[FBSession activeSession] accessTokenData] userID];
    
    if (!accessToken || !facebookID) {
        NSLog(@"Login failure. FB Access Token or user ID does not exist");
        return;
    }
    
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if ([[FBSession activeSession] respondsToSelector:@selector(clearAffinitizedThread)]) {
        [[FBSession activeSession] performSelector:@selector(clearAffinitizedThread)];
    }
    
    [PFFacebookUtils logInWithFacebookId:facebookID accessToken:accessToken expirationDate:expirationDate block:^(PFUser *user, NSError *error) {
        if (error == nil) {
            [self.progressHUD removeFromSuperview];
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(logInViewControllerDidLogUserIn:)]) {
                    [self.delegate performSelector:@selector(logInViewControllerDidLogUserIn:) withObject:user];
                }
            }
        } else {
            [self handleLogInError:error];
            [self.progressHUD removeFromSuperview];
            [[FBSession activeSession] closeAndClearTokenInformation];
            [PFUser logOut];
        }
    }];
    
}

# pragma mark - ()

- (void)handleLogInError:(NSError *)error {
    NSLog(@"Error: %@", [[error userInfo] objectForKey:@"com.facebook.sdk:ErrorLoginFailedReason"]);
    
    if ([[[error userInfo] objectForKey:@"com.facebook.sdk:ErrorLoginFailedReason"] isEqualToString:@"com.facebook.sdk:UserLoginCancelled"]) {
        return;
    }
    
    if (error.code == kPFErrorFacebookInvalidSession) {
        NSLog(@"Invalid session, logging out.");
        [[FBSession activeSession] closeAndClearTokenInformation];
        return;
    }
    
    if (error.code == kPFErrorConnectionFailed) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Something went wrong. Please try again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"Something went wrong. Please try again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

@end
