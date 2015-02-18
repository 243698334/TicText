//
//  TTConstants.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/6/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTConstants.h"

#pragma mark - UIColors
// UI Purple color
float const kTTUIPurpleColorRed = 130.0;
float const kTTUIPurpleColorGreen = 100.0;
float const kTTUIPurpleColorBlue = 200.0;
float const kTTUIPurpleColorAlpha = 255.0;


#pragma mark - NSUserDefaults


#pragma mark - NSNotification


#pragma mark - PFUser Class
// Field keys
NSString * const kTTUserDisplayNameKey = @"displayName";
NSString * const kTTUserFacebookIDKey = @"facebookId";
NSString * const kTTUserProfilePictureKey = @"profilePicture";
NSString * const kTTUserProfilePictureSmallKey = @"profilePictureSmall";
NSString * const kTTUserTicTextFriendsKey = @"ticTextFriends";
NSString * const kTTUserHasTicTextProfileKey = @"hasTicTextProfile";


#pragma mark - PFObject Tic Class
// Class key
NSString * const kTTTicClassKey = @"Tic";

// Field keys
NSString * const kTTTicSenderKey = @"sender";
NSString * const kTTTicRecipientKey = @"recipient";
NSString * const kTTTicTimeLimitKey = @"timeLimit";
NSString * const kTTTicSendTimestampKey = @"sendTimestamp";
NSString * const kTTTicReceiveTimestampKey = @"receiveTimestamp";
NSString * const kTTTicStatusKey = @"status";
NSString * const kTTTicContentKey = @"content";


#pragma mark - PFObject Activity Class
// Class key
NSString * const kTTActivityClassKey = @"Activity";

// Type values
NSString * const kTTActivityTypeSend = @"send";
NSString * const kTTActivityTypeFetch = @"fetch";

// Field keys
NSString * const kTTActivityTypeKey = @"type";
NSString * const kTTActivityFromUserKey = @"fromUser";
NSString * const kTTActivityToUserKey = @"toUser";
NSString * const kTTActivityContentKey = @"content";
NSString * const kTTActivityTicKey = @"tic";
