//
//  TTLogInViewController.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/7/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTLogInViewController.h"

#import <MBProgressHUD/MBProgressHUD.h>

#import "TTSession.h"
#import "TTUtility.h"
#import "TTFindFriendsViewController.h"

@interface TTLogInViewController ()

@property (nonatomic, strong) MBProgressHUD *progressHUD;

@end

@implementation TTLogInViewController

- (instancetype)init {
    if (self = [super init]) {
        self.presentForLogIn = YES;
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kTTUIPurpleColor;
    
    self.facebookLogInView.readPermissions = kTTFacebookPermissions;
}

#pragma mark - FBLogInViewDelegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    if (!self.presentForLogIn) {
        // Reset the button to the right state (show "Log in with Facebook" instead of "Log out")
        [FBSession.activeSession closeAndClearTokenInformation];
        return;
    }
    
    // Show loading indicator until login is finished
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[TTSession sharedSession] login:^(BOOL isNewUser, NSError *error) {
        [self.progressHUD removeFromSuperview];
        
        if (error) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        } else {
            [TTUtility setupPushNotifications];
            
            BOOL showFindFriends = isNewUser || ![[TTUser currentUser] isLinkedWithFacebook];
            
            if (showFindFriends) {
                __block BOOL shouldReturn = NO;
                [TTSession.sharedSession syncProfileData:^(NSError *error) {
                    if (error) {
                        NSString *errorMessage = @"Uh oh. Unable to create your account. Please try again later.";
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error"
                                                                        message:errorMessage
                                                                       delegate:nil
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"Dismiss", nil];
                        [alert show];
                        
                        shouldReturn = YES;
                    } else {
                        [TTSession.sharedSession syncFriends:nil];
                        [TTSession.sharedSession syncProfilePicture:nil];
                    }
                }];
                
                if (shouldReturn) {
                    return;
                }
            }
            
            [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
                if (showFindFriends) {
                    TTFindFriendsViewController *findFriendsViewController =
                    [[TTFindFriendsViewController alloc] init];
                    
                    findFriendsViewController.modalTransitionStyle =
                    UIModalTransitionStyleCrossDissolve;
                    
                    [self.presentingViewController presentViewController:findFriendsViewController
                                                                animated:YES
                                                              completion:nil];
                }
            }];
        }
    }];
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    self.presentForLogIn = YES;
}

@end
