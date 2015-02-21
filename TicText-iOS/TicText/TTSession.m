//
//  TTSession.m
//  TicText
//
//  Created by Terrence K on 2/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTSession.h"

#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@implementation TTSession

+ (TTSession *)sharedSession {
    static TTSession *_sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[TTSession alloc] init];
    });
     
    return _sharedInstance;
}

- (BOOL)isUserLoggedIn {
    return [TTUser currentUser] != nil;
}

- (void)login:(void (^)(BOOL isNewUser, NSError *error))completion {
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:kTTFacebookPermissions block:^(PFUser *user, NSError *error) {
        if (!user) {
            if (completion) {
                completion(NO, error);
            }
        } else {
            if (completion) {
                completion(user.isNew, error);
            }
        }
    }];
}

- (void)logout:(void (^)(void))completion {
    [TTUser logOut];
    [FBSession.activeSession closeAndClearTokenInformation];
    
    if (completion) {
        completion();
    }
}

#pragma mark - FBSync

- (void)syncProfileData:(void (^)(NSError *error))completion {
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
