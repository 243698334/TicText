//
//  TTSession.m
//  TicText
//
//  Created by Terrence K on 2/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTSession.h"

@implementation TTSession

+ (TTSession *)sharedSession {
    static TTSession *_sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[TTSession alloc] init];
    });
     
    return _sharedInstance;
}

- (BOOL)isValidLastChecked {
    BOOL isParseSessionValid = [[NSUserDefaults standardUserDefaults] boolForKey:kTTParseSessionIsValidLastCheckedKey];
    BOOL isFacebookSessionValid = [[NSUserDefaults standardUserDefaults] boolForKey:kTTFacebookSessionIsValidLastCheckedKey];
    NSLog(@"TTSession: Parse session %@ last checked", isParseSessionValid ? @"VALID" : @"INVALID");
    NSLog(@"TTSession: Facebook session %@ last checked", isFacebookSessionValid ? @"VALID" : @"INVALID");
    return isParseSessionValid && isFacebookSessionValid;
}

- (void)validateSessionInBackground {
    // Validate Parse session
    if (![TTUser currentUser]) {
        NSLog(@"TTSession: Parse local session INVALID. ");
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kTTParseSessionIsValidLastCheckedKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTTParseSessionDidBecomeInvalidNotification object:nil];
        return;
    } else {
        PFQuery *validateParseSessionQuery = [TTUser query];
        [validateParseSessionQuery whereKey:@"facebookID" equalTo:[[TTUser currentUser] facebookId]];
        [validateParseSessionQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (number != 1 || error) {
                NSLog(@"TTSession: Parse remote session INVALID. ");
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kTTParseSessionIsValidLastCheckedKey];
                [[NSNotificationCenter defaultCenter] postNotificationName:kTTParseSessionDidBecomeInvalidNotification object:nil];
                return;
            } else {
                NSLog(@"TTSession: Parse remote session VALID. ");
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kTTParseSessionIsValidLastCheckedKey];
            }
        }];
    }
    
    // Validate Facebook session
    [[PFFacebookUtils session] refreshPermissionsWithCompletionHandler:^(FBSession *session, NSError *error) {
        if (error) {
            NSLog(@"TTSession: Facebook session INVALID. ");
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kTTFacebookSessionIsValidLastCheckedKey];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTFacebookSessionDidBecomeInvalidNotification object:nil userInfo:[NSDictionary dictionaryWithObject:error forKey:@"error"]];
            return;
        } else {
            NSLog(@"TTSession: Facebook session VALID. ");
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kTTFacebookSessionIsValidLastCheckedKey];
        }
    }];
}

- (void)validateSessionWithCompletionHandler:(void (^)(BOOL isValid, NSError *error))completionHandler {
    if (![TTUser currentUser] || ![[TTUser currentUser] facebookId]) {
        // Check for Parse login status locally first
        NSLog(@"TTSession: Parse session INVALID. Skip Facebook session validaton. ");
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kTTParseSessionIsValidLastCheckedKey];
        if (completionHandler) {
            completionHandler(NO, nil);
            return;
        }
    } else {
        // Check if current user still in cloud datastore
        PFQuery *queryForSessionValidation = [TTUser query];
        [queryForSessionValidation whereKey:@"facebookID" equalTo:[[TTUser currentUser] facebookId]];
        if ([queryForSessionValidation countObjects] > 0) {
            NSLog(@"TTSession: Parse session VALID. Proceed to Facebook session validation. ");
        } else {
            NSLog(@"TTSession: Parse session INVALID. Skip Facebook session validaton. ");
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kTTParseSessionIsValidLastCheckedKey];
            if (completionHandler) {
                completionHandler(NO, nil);
                return;
            }
        }
    }
    // Facebook validation
    [[PFFacebookUtils session] refreshPermissionsWithCompletionHandler:^(FBSession *session, NSError *error) {
        if (error) {
            NSLog(@"TTSession: Facebook session INVALID. ");
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kTTFacebookSessionIsValidLastCheckedKey];
            if (completionHandler) {
                completionHandler(NO, error);
            }
        } else {
            NSLog(@"TTSession: Facebook session VALID. ");
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kTTFacebookSessionIsValidLastCheckedKey];
            if (completionHandler) {
                completionHandler(YES, error);
            }
        }
    }];
}


- (void)logIn:(void (^)(BOOL isNewUser, NSError *error))completion {
    // Login PFUser using Facebook
    NSLog(@"TTSession: Logging in. ");
    [PFFacebookUtils logInWithPermissions:kTTFacebookPermissions block:^(PFUser *user, NSError *error) {
        if (!user) {
            if (completion) {
                completion(NO, error);
            }
        } else {
            if (completion) {
                NSLog(@"Logged in with permissions: %@", kTTFacebookPermissions);
                NSLog(@"Name: [%@], FacebookID: [%@], Friends: [%@]", [(TTUser *)user displayName], [(TTUser *)user displayName], [(TTUser *)user displayName]);
                completion(user.isNew, error);
            }
        }
    }];
}

- (void)logOut:(void (^)(void))completion {
    NSLog(@"TTSession: Logging out. ");
    [TTUser logOut];
    [[PFFacebookUtils session] closeAndClearTokenInformation];
    
    if (completion) {
        completion();
    }
}

- (void)handleAuthenticationError:(NSError *)error {
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        [self showAlertViewWithErrorTitle:@"Something went wrong" errorMessage:[FBErrorUtility userMessageForError:error]];
    } else {
        if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
            // log in cancelled
            NSLog(@"Log in cancelled error: %@", error);
            [self showAlertViewWithErrorTitle:@"Login cancelled" errorMessage:@"Please log back in with Facebook. "];
        } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
            // invalid session
            NSLog(@"Invalid session error: %@", error);
            [self showAlertViewWithErrorTitle:@"Session Error" errorMessage:@"Your current session is no longer valid. Please log in agian. "];
        } else {
            NSLog(@"Other error: %@", error);
            [self showAlertViewWithErrorTitle:@"Something went wrong" errorMessage:@"Please retry"];
        }
    }
}

- (void)showAlertViewWithErrorTitle:(NSString *)title errorMessage:(NSString *)message {
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}


#pragma mark - FBSync

- (void)syncFacebookProfileForNewUser:(void (^)(NSError *error))completion {
    NSLog(@"Sync Facebook profile for new user. ");
    FBRequestConnection *facebookRequestConnection = [[FBRequestConnection alloc] init];
    [facebookRequestConnection addRequest:[FBRequest requestWithGraphPath:@"me" parameters:@{@"fields": @"name,id,friends,picture.height(640).width(640)"} HTTPMethod:@"GET"] completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error == nil) {
            NSString *displayName = result[@"name"];
            NSString *facebookID = result[@"id"];
            NSArray *friends = result[@"friends"][@"data"] == nil ? [NSArray arrayWithObjects:nil] : result[@"friends"][@"data"];
            NSURL *profilePictureURL = [NSURL URLWithString:result[@"picture"][@"data"][@"url"]];
            NSLog(@"Name: [%@], FacebookID: [%@], Friends: [%@], Profile picture URL: [%@]", displayName, facebookID, friends, profilePictureURL);
            
            [[TTUser currentUser] setDisplayName:displayName];
            [[TTUser currentUser] setFacebookId:facebookID];
            [[TTUser currentUser] setFriends:friends];
            NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL];
            [NSURLConnection sendAsynchronousRequest:profilePictureURLRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                 if (connectionError == nil && data != nil) {
                     [[TTUser currentUser] setProfilePicture:data];
                     [[TTUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                         if (completion) {
                             completion(error);
                         }
                     }];
                 } else {
                     if (completion) {
                         completion(connectionError);
                     }
                 }
             }];
        } else {
            if (completion) {
                completion(error);
            }
        }
    }];
    [facebookRequestConnection start];
}


- (void)syncProfileData:(void (^)(NSError *error))completion {
    NSLog(@"Sync profile data");
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *conn, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            
            NSDictionary *dataMap = @{
                                      kTTUserDisplayNameKey :   @"name",
                                      kTTUserFacebookIDKey :    @"id"
                                      };
            
            TTUser *user = [TTUser currentUser];
            [dataMap enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
                user[key] = userData[obj];
            }];
            
            // @TODO: saveInBackgroundWithBlock should run asynchronously with completion block
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (completion) {
                    completion(error);
                }
            }];
        }
        if (completion) {
            completion(error);
        }
    }];
}

- (void)syncFriends:(void (^)(NSError *))completion {
    NSLog(@"Sync friends. ");
    FBRequest *request = [FBRequest requestForMyFriends];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSMutableArray *friendIds = [NSMutableArray array];
            
            NSArray *friends = [result objectForKey:@"data"];
            for (NSDictionary *friend in friends) {
                [friendIds addObject:friend[@"id"]];
            }
            
            TTUser *user = [TTUser currentUser];
            [user setFriends:[NSArray arrayWithArray:friendIds]];
            
            // @TODO: saveInBackgroundWithBlock should run asynchronously with completion block
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (completion) {
                    completion(error);
                }
            }];
        }
        if (completion) {
            completion(error);
        }
    }];
}

- (void)syncProfilePicture:(void (^)(NSError *))completion {
    NSLog(@"Sync profile picture. ");
    TTUser *user = [TTUser currentUser];
    
    void (^fetchProfilePicture)(NSString *) = ^(NSString *facebookId){
        NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookId]];
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
        
        // Run network request asynchronously
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:
         ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
             if (connectionError == nil && data != nil) {
                 [user setProfilePicture:data];
                 [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                     if (completion) {
                         completion(error);
                     }
                 }];
             }
         }];
    };
    
    if ([user facebookId]) {
        fetchProfilePicture([user facebookId]);
    } else {
        [self syncProfileData:^(NSError *error) {
            if (!error) {
                fetchProfilePicture([user facebookId]);
            } else if (completion) {
                completion(error);
            }
        }];
    }
}

@end
