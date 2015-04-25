//
//  TTSessionNew.m
//  TicText
//
//  Created by Kevin Yufei Chen on 4/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTSession.h"

#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "Reachability.h"
#import "TTUtility.h"
#import "TTErrorHandler.h"
#import "TTUser.h"
#import "TTActivity.h"

@implementation TTSession

static BOOL isValidating = NO;

+ (void)logInWithBlock:(nonnull void (^)(BOOL isNewUser, NSError *error))resultBlock {
    // Start monitoring Reachability changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:kReachabilityChangedNotification object:nil];
    
    // When Parse server is unreachable, continue to the main UI.
    if (![TTUtility isParseReachable]) {
        resultBlock(NO, nil);
        return;
    }
    
    [PFFacebookUtils logInWithPermissions:kTTFacebookPermissions block:^(PFUser *user, NSError *error) {
        if (error) {
            resultBlock(NO, error);
            return;
        } else {
            if (user.isNew) {
                [self syncNewUserDataWithBlock:resultBlock];
            } else {
                [self syncExistingUserDataWithBlock:resultBlock];
            }
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kTTSessionIsValidLastCheckedKey];
        }
    }];
}

+ (void)logOutWithBlock:(nonnull void (^)(NSError * __nullable error))resultBlock {
    // Stop monitoring Reachability changes
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kTTSessionIsValidLastCheckedKey];
    
    [TTUser logOutInBackgroundWithBlock:^(NSError *error) {
        [[PFFacebookUtils session] closeAndClearTokenInformation];
        [FBSession.activeSession closeAndClearTokenInformation];
        [FBSession.activeSession close];
        [FBSession setActiveSession:nil];
        [[PFInstallation currentInstallation] removeObjectForKey:kTTInstallationUserKey];
        [[PFInstallation currentInstallation] saveInBackground];
        [PFQuery clearAllCachedResults];
    }];
    
    resultBlock(nil);
}

+ (void)validateSessionInBackground {
    // Skip when there's a pending validation
    if (isValidating) {
        NSLog(@"Ongoing validation.");
        return;
    }
    
    // Skip when Parse is not reachable
    if (![TTUtility isParseReachable] || ![TTUtility isInternetReachable]) {
        NSLog(@"Parse not reachable. Skip validation.");
        return;
    }
    
    isValidating = YES;
    
    // Check if user is logged out
    if (![TTUser currentUser]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kTTSessionIsValidLastCheckedKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTTSessionDidBecomeInvalidNotification object:nil];
        isValidating = NO;
        return;
    }
    
    // Validate Parse session
    [self getCurrentSessionInBackgroundWithBlock:^(PFSession *session, NSError *error) {
        if (error) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kTTSessionIsValidLastCheckedKey];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTSessionDidBecomeInvalidNotification object:nil userInfo:[NSDictionary dictionaryWithObject:error forKey:kTTNotificationUserInfoErrorKey]];
            [TTErrorHandler handleParseSessionError:error inViewController:nil];
        } else {
            [[TTUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                [[TTUser currentUser].privateData fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    if ([[TTUser currentUser].privateData.activeDeviceIdentifier isEqualToString:[UIDevice currentDevice].identifierForVendor.UUIDString]) {
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kTTSessionIsValidLastCheckedKey];
                    } else {
                        NSDictionary *uuidErrorUserInfo = @{NSLocalizedDescriptionKey: @"Invalid Session",
                                                            NSLocalizedFailureReasonErrorKey: @"Your account has been logged in with another device.",
                                                            NSLocalizedRecoverySuggestionErrorKey: @"Consider turn on 2-step verification or TicText password."};
                        NSError *uuidError = [NSError errorWithDomain:kTTSessionErrorDomain code:kTTSessionErrorParseSessionInvalidUUIDCode userInfo:uuidErrorUserInfo];
                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kTTSessionIsValidLastCheckedKey];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kTTSessionDidBecomeInvalidNotification object:nil userInfo:@{kTTNotificationUserInfoErrorKey: uuidError}];
                        [TTErrorHandler handleParseSessionError:uuidError inViewController:nil];
                    }

                }];
            }];
        }
        isValidating = NO;
    }];
}

+ (BOOL)isValidLastChecked {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kTTSessionIsValidLastCheckedKey];
}

+ (void)reachabilityDidChange:(NSNotification *)notification {
    [self validateSessionInBackground];
}

+ (void)syncFriendsDataInBackground {
    NSLog(@"Current TTUser object is %@dirty.", [TTUser currentUser].isDirty ? @"" : @"NOT ");
    NSLog(@"Current TTUser PrivateData object is %@dirty.", [TTUser currentUser].privateData.isDirty ? @"" : @"NOT ");
    NSLog(@"Current TTUser PrivateData friends attribute is %@dirty.", [[TTUser currentUser].privateData isDirtyForKey:kTTUserPrivateDataFriendsKey] ? @"" : @"NOT ");
    if ([TTUtility isParseReachable]) {
        [[TTUser currentUser].privateData fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [TTUser fetchAllIfNeededInBackground:[TTUser currentUser].privateData.friends];
        }];
    }
}

+ (void)syncNewUserDataWithBlock:(nonnull void (^)(BOOL isNewUser, NSError * __nullable error))resultBlock {
    FBRequestConnection *facebookRequestConnection = [[FBRequestConnection alloc] init];
    [facebookRequestConnection addRequest:[FBRequest requestWithGraphPath:@"me" parameters:@{@"fields": @"name,id,friends,picture.height(640).width(640)"} HTTPMethod:@"GET"] completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            resultBlock(YES, error);
        } else {
            NSString *displayName = result[@"name"];
            NSString *facebookId = result[@"id"];
            NSArray *facebookFriends = result[@"friends"][@"data"];
            NSMutableArray *facebookFriendsIds = [[NSMutableArray alloc] initWithCapacity:[facebookFriends count]];
            for (NSDictionary *currentFacebookFriendEntry in facebookFriends) {
                [facebookFriendsIds addObject:[currentFacebookFriendEntry objectForKey:@"id"]];
            }
            NSURL *profilePictureURL = [NSURL URLWithString:result[@"picture"][@"data"][@"url"]];
            NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL];
            NSURLResponse *profilePictureURLResponse = nil;
            NSError *profilePictureRequestError = nil;
            
            [TTUser currentUser].facebookId = facebookId;
            [TTUser currentUser].displayName = displayName;
            [TTUser currentUser].privateData = [TTUserPrivateData object];
            [TTUser currentUser].privateData.userId = [TTUser currentUser].objectId;
            [TTUser currentUser].privateData.ACL = [PFACL ACLWithUser:[TTUser currentUser]];
            [TTUser currentUser].privateData.facebookFriends = facebookFriendsIds;
            [TTUser currentUser].privateData.activeDeviceIdentifier = [UIDevice currentDevice].identifierForVendor.UUIDString;
            [TTUser currentUser].profilePicture = [PFFile fileWithData:[NSURLConnection sendSynchronousRequest:profilePictureURLRequest returningResponse:&profilePictureURLResponse error:&profilePictureRequestError]];
            
            [[TTUser currentUser] save];
            
            [[TTUser currentUser].privateData fetch];
            [[TTUser currentUser].privateData pinWithName:kTTLocalDatastorePrivateDataPinName];
            [TTUser fetchAll:[TTUser currentUser].privateData.friends];
            [TTUser unpinAllObjectsWithName:kTTLocalDatastoreFriendsPinName];
            [TTUser pinAll:[TTUser currentUser].privateData.friends withName:kTTLocalDatastoreFriendsPinName];
            
            [[TTActivity activityWithType:kTTActivityTypeNewUserJoin] saveInBackground];
            
            resultBlock(YES, nil);
        }
    }];
    [facebookRequestConnection start];
}

+ (void)syncExistingUserDataWithBlock:(nonnull void (^)(BOOL isNewUser, NSError * __nullable error))resultBlock {
    [TTUser currentUser].privateData.activeDeviceIdentifier = [UIDevice currentDevice].identifierForVendor.UUIDString;
    [[FBRequest requestForMyFriends] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            resultBlock(NO, error);
        } else {
            NSArray *facebookFriends = result[@"data"];
            NSMutableArray *facebookFriendsIds = [[NSMutableArray alloc] initWithCapacity:[facebookFriends count]];
            for (NSDictionary *currentFacebookFriendEntry in facebookFriends) {
                [facebookFriendsIds addObject:[currentFacebookFriendEntry objectForKey:@"id"]];
            }
            [TTUser currentUser].privateData.facebookFriends = facebookFriendsIds;
            [[TTUser currentUser] save];
            
            NSLog(@"Current TTUser object is %@dirty.", [TTUser currentUser].isDirty ? @"" : @"NOT ");
            NSLog(@"Current TTUser PrivateData object is %@dirty.", [TTUser currentUser].privateData.isDirty ? @"" : @"NOT ");
            NSLog(@"Current TTUser PrivateData friends attribute is %@dirty.", [[TTUser currentUser].privateData isDirtyForKey:kTTUserPrivateDataFriendsKey] ? @"" : @"NOT ");
            
            [[TTUser currentUser].privateData pinWithName:kTTLocalDatastorePrivateDataPinName];
            [TTUser fetchAllIfNeededInBackground:[TTUser currentUser].privateData.friends block:^(NSArray *objects, NSError *error) {
                if (!error) {
                    [TTUser unpinAllObjectsWithName:kTTLocalDatastoreFriendsPinName];
                    [TTUser pinAll:[TTUser currentUser].privateData.friends withName:kTTLocalDatastoreFriendsPinName];
                    // TODO: should not unpinAll.
                }
            }];
            
            resultBlock(NO, nil);
        }
    }];

}

+ (void)cacheFriendsProfilePicturesInBackground {
    [TTUser fetchAllIfNeededInBackground:[TTUser currentUser].privateData.friends block:^(NSArray *objects, NSError *error) {
        
    }];
}





@end
