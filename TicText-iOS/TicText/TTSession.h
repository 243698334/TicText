//
//  TTSessionNew.h
//  TicText
//
//  Created by Kevin Yufei Chen on 4/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <Parse/Parse.h>

@interface TTSession : PFSession

/*!
 @abstract Start the log in process.
 @discussion Should be called within an async queue.
 @param resultBlock The result block for the caller to handle errors and other completion calls.
 */
+ (void)logInWithBlock:(nonnull void (^)(BOOL isNewUser, NSError * __nullable error))resultBlock;

/*!
 @abstract Start the log out process.
 @param resultBlock The result block for the caller to handle errors and other completion calls.
 */
+ (void)logOutWithBlock:(nonnull void (^)(NSError * __nullable error))resultBlock;

/*!
 @abstract Asynchromously validate the currerent session.
 @discussion This method will post a `kTTSessionDidBecomeInvalidNotification` when an invalid session is detected. 
 @discussion It will also store the result of the lastest validation to NSUserDefaults.
 */
+ (void)validateSessionInBackground;

/*!
 @abstract Get the result of the latest validation status.
 @discussion The result is based on the boolean value stored in NSUserDefaults.
 @return A boolean value indicating if the session was valid last checked.
 */
+ (BOOL)isValidLastChecked;

/*!
 @abstract Asynchromously sync all friends of the current user.
 @discussion This will not download the profile pictures until loaded somewhere else.
 */
+ (void)syncFriendsDataInBackground;

@end
