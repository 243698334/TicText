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
    
    // Background
    self.view.backgroundColor = [UIColor colorWithRed:kTTUIPurpleColorRed/255.0 green:kTTUIPurpleColorGreen/255.0 blue:kTTUIPurpleColorBlue/255.0 alpha:kTTUIPurpleColorAlpha/255.0];
    
    // check user login status
    if ([PFUser currentUser] == nil) {
        // if not logged in, present LogInViewController
        [self presentLogInViewControllerAnimated:NO];
        return;
    } else {
        // if logged in, sync user data
        [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [self refreshDataForExistingUser:(PFUser *)object error:error completion:nil];
        }];
    }

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

- (void)logInViewControllerDidLogUserIn:(PFUser *)currentUser {
    if (_logInViewControllerPresented) {
        _logInViewControllerPresented = NO;
        [self dismissViewControllerAnimated:YES completion:nil];
        
        if ([currentUser objectForKey:kTTUserHasTicTextProfileKey]) {
            // user already has TicText profile
            [self refreshDataForExistingUser:currentUser error:nil completion:nil];
        } else {
            // new user
            [currentUser setObject:@YES forKey:kTTUserHasTicTextProfileKey];
            [self fetchDataForNewUser:currentUser error:nil completion:^{
                // Present TTFindFriendsViewController if new user
                TTFindFriendsViewController *findFriendsViewController = [[TTFindFriendsViewController alloc] init];
                findFriendsViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentViewController:findFriendsViewController animated:YES completion:nil];
            }];
        }
    }
}

#pragma mark - ()

- (void)fetchDataForNewUser:(PFUser *)currentUser error:(NSError *)error completion:(void (^)(void))completion {
    // Error handling
    if (error != nil) {
        [self showAlertWithErrorDescription:error.description];
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] currentUserLogOut];
        return;
    }
    
    [[PFFacebookUtils session] refreshPermissionsWithCompletionHandler:^(FBSession *session, NSError *error) {
        // Check for Facebook session error
        if (error != nil) {
            NSLog(@"Failed refresh of FB Session, logging out: %@", error);
            [self showAlertWithErrorDescription:@"Please check if you canceled the Facebook authentication for TicText. Or you can just simply log back in. "];
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] currentUserLogOut];
            return;
        }
        
        // Fetch display name, TicText friend list, profile picture
        if ([session.accessTokenData.permissions containsObject:@"user_friends"]) {
            FBRequestConnection *facebookRequestConnection = [[FBRequestConnection alloc] init];
            [facebookRequestConnection addRequest:[FBRequest requestWithGraphPath:@"me" parameters:@{@"fields": @"name,friends,picture.height(640).width(640)"} HTTPMethod:@"GET"] completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (error != nil) {
                    [self showAlertWithErrorDescription:error.description];
                } else {
                    // display name
                    NSString *displayName = result[@"name"];
                    [currentUser setObject:displayName forKey:kTTUserDisplayNameKey];
                    
                    // TicText friend list
                    NSArray *facebookFriendsDataArray = result[@"friends"][@"data"];
                    NSMutableArray *facebookFriends = [[NSMutableArray alloc] initWithCapacity:[facebookFriendsDataArray count]];
                    for (NSDictionary *currentFacebookFriendEntry in facebookFriendsDataArray) {
                        [facebookFriends addObject:[currentFacebookFriendEntry objectForKey:@"id"]];
                    }
                    [currentUser setObject:facebookFriends forKey:kTTUserTicTextFriendsKey];
                    
                    // profile picture
                    NSURL *profilePictureURL = [NSURL URLWithString:result[@"picture"][@"data"][@"url"]];
                    NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
                    AFHTTPRequestOperation *fetchProfilePictureRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:profilePictureURLRequest];
                    fetchProfilePictureRequestOperation.responseSerializer = [AFImageResponseSerializer serializer];
                    [fetchProfilePictureRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                        NSLog(@"Response: %@", responseObject);
                        NSData *profilePictureData = UIImageJPEGRepresentation(responseObject, 1.0);
                        PFFile *profilePictureFile = [PFFile fileWithData:profilePictureData];
                        [currentUser setObject:profilePictureFile forKey:kTTUserProfilePictureKey];
                        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (succeeded) {
                                NSLog(@"New User: Successfully updated current user data. ");
                            } else {
                                NSLog(@"New User: Error saving user data, Error: %@", error);
                            }
                        }];
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"Profile picture fetch error: %@", error);
                    }];
                    [fetchProfilePictureRequestOperation start];
                    
                    NSLog(@"New User: Display name: %@, Friend list: %@, Profile Picture URL: %@", displayName, facebookFriends, profilePictureURL);
                    
                    if (completion != nil) {
                        completion();
                    }
                }
            }];
            [facebookRequestConnection start];
        } else {
            NSLog(@"Permission error. ");
            [self showAlertWithErrorDescription:@"Please check if you have Friends List permission turned on. Or you can just simply log back in. "];
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] currentUserLogOut];
        }
    }];
}

- (void)refreshDataForExistingUser:(PFUser *)currentUser error:(NSError *)error completion:(void (^)(void))completion {
    // Error handling
    if (error != nil) {
        [self showAlertWithErrorDescription:error.description];
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] currentUserLogOut];
        return;
    }
    
    [[PFFacebookUtils session] refreshPermissionsWithCompletionHandler:^(FBSession *session, NSError *error) {
        // Check for Facebook session error
        if (error != nil) {
            NSLog(@"Failed refresh of FB Session, logging out: %@", error);
            [self showAlertWithErrorDescription:@"Please check if you canceled the Facebook authentication for TicText. Or you can just simply log back in. "];
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] currentUserLogOut];
            return;
        }
        
        // Update TicText friend list
        if ([session.accessTokenData.permissions containsObject:@"user_friends"]) {
            FBRequestConnection *facebookRequestConnection = [[FBRequestConnection alloc] init];
            [facebookRequestConnection addRequest:[FBRequest requestForMyFriends] completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (error != nil) {
                    [self showAlertWithErrorDescription:error.description];
                } else {
                    // TicText friend list is exactly the same as Facebook friend list
                    NSArray *facebookFriendsDataArray = [result objectForKey:@"data"];
                    NSMutableArray *facebookFriends = [[NSMutableArray alloc] initWithCapacity:[facebookFriendsDataArray count]];
                    for (NSDictionary *currentFacebookFriendEntry in facebookFriendsDataArray) {
                        [facebookFriends addObject:[currentFacebookFriendEntry objectForKey:@"id"]];
                    }
                    [currentUser setObject:facebookFriends forKey:kTTUserTicTextFriendsKey];
                    NSLog(@"TicText friend list for current user: %@", facebookFriends);
                }
                
                // catch response and run the completion block after all responses have been received
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"Successfully updated current user data. ");
                    } else {
                        NSLog(@"Unable to update current user data. ");
                    }
                }];
                
                if (completion != nil) {
                    completion();
                }
            }];
            [facebookRequestConnection start];
        } else {
            NSLog(@"Permission error. ");
            [self showAlertWithErrorDescription:@"Please check if you have Friends List permission turned on. Or you can just simply log back in. "];
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] currentUserLogOut];
        }
        
    }];
}


- (void)showAlertWithErrorDescription:(NSString *)errorDescription {
    UIAlertView *errorMessageAlertView = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:errorDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorMessageAlertView show];
}


@end
