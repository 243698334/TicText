//
//  TTLogInViewController.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/7/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTLogInViewController.h"

@interface TTLogInViewController ()

@property (nonatomic, strong) MBProgressHUD *progressHUD;

@end

@implementation TTLogInViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kTTUIPurpleColor;
    self.facebookLogInView.readPermissions = kTTFacebookPermissions;
}


#pragma mark - FBLogInViewDelegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    // Show loading indicator until login is finished
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[TTSession sharedSession] logIn:^(BOOL isNewUser, NSError *error) {
        if (error) {
            NSString *errorMessage = nil;
            if (!error) {
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                errorMessage = [error localizedDescription];
            }
            [[[UIAlertView alloc] initWithTitle:@"Log In Error" message:errorMessage delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
        } else {
            if (isNewUser) {
                // New user sign up
                [[TTSession sharedSession] syncForNewUser:^(NSError *error) {
                    if (error != nil) {
                        NSLog(@"Sign up error: %@", error);
                        NSString *errorMessage = @"Uh oh. Unable to create your account. Please try again later.";
                        [[[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:errorMessage delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
                    } else {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kTTLogInViewControllerDidFinishSignUpNotification object:nil];
                    }
                    [self.progressHUD removeFromSuperview];
                }];
            } else {
                // Existing user log in
                [[TTSession sharedSession] syncForExistingUser:^(NSError *error) {
                    if (error != nil) {
                        NSString *errorMessage = @"Uh oh. Unable to refresh your profile. Please try again later.";
                        [[[UIAlertView alloc] initWithTitle:@"Log In Error" message:errorMessage delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
                    } else {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kTTLogInViewControllerDidFinishLogInNotification object:nil];
                    }
                    [self.progressHUD removeFromSuperview];
                }];
            }
        }
    }];
}

@end
