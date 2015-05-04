//
//  TTLogInViewController.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/7/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTLogInViewController.h"

#import "TTSession.h"

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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [TTSession logInWithBlock:^(BOOL isNewUser, NSError *error) {
            if (error) {
                [[[UIAlertView alloc] initWithTitle:@"Log In Failed" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else {
                if (isNewUser) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTTLogInViewControllerDidFinishSignUpNotification object:nil];
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTTLogInViewControllerDidFinishLogInNotification object:nil];
                }
                [self.progressHUD removeFromSuperview];
            }
        }];
    });
}

@end
