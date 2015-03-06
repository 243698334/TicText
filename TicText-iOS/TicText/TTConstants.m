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
NSString * const kTTParseSessionIsValidLastCheckedKey = @"ParseSessionIsValidLastCheckedKey";
NSString * const kTTFacebookSessionIsValidLastCheckedKey = @"FacebookSessionIsValidLastCheckedKey";


#pragma mark - NSNotification
// Log in, Sign up, Log out
NSString * const kTTLogInViewControllerDidFinishLogInNotification = @"TTLogInViewControllerDidFinishLogInNotification";
NSString * const kTTLogInViewControllerDidFinishSignUpNotification = @"TTLogInViewControllerDidFinishLogInNewUserNotification";
NSString * const kTTUserDidLogOutNotification = @"UserDidLogOut";

// Invalid session
NSString * const kTTFacebookSessionDidBecomeInvalidNotification = @"FacebookSessionDidBecomeInvalidNotification";
NSString * const kTTParseSessionDidBecomeInvalidNotification = @"ParseSessionDidBecomeInvalidNotification";

// Push notification
NSString * const kTTApplicationDidReceiveNewTicWhileActiveNotification = @"TTApplicationDidReceiveNewTicWhileActiveNotification";


#pragma mark - NSError
NSString * const kTTErrorUserInfoKey = @"error";
NSString * const kTTSessionErrorDomain = @"SessionError";
NSUInteger const kTTSessionErrorParseSessionFetchFailureCode = 0;
NSUInteger const kTTSessionErrorParseSessionInvalidUUIDCode = 1;


#pragma mark - PFUser Class
// Field keys
NSString * const kTTUserDisplayNameKey = @"displayName";
NSString * const kTTUserFacebookIDKey = @"facebookID";
NSString * const kTTUserProfilePictureKey = @"profilePicture";
NSString * const kTTUserProfilePictureSmallKey = @"profilePictureSmall";
NSString * const kTTUserTicTextFriendsKey = @"ticTextFriends";
NSString * const kTTUserActiveDeviceIdentifier = @"activeDeviceIdentifier";


#pragma mark - PFObject Tic Class
// Class key
NSString * const kTTTicClassKey = @"Tic";

// Field keys
NSString * const kTTTicSenderKey = @"sender";
NSString * const kTTTicTypeKey = @"type";
NSString * const kTTTicRecipientKey = @"recipient";
NSString * const kTTTicTimeLimitKey = @"timeLimit";
NSString * const kTTTicSendTimestampKey = @"sendTimestamp";
NSString * const kTTTicReceiveTimestampKey = @"receiveTimestamp";
NSString * const kTTTicStatusKey = @"status";
NSString * const kTTTicContentTypeKey = @"contentType";
NSString * const kTTTicContentKey = @"content";

// Type values
NSString * const kTTTicTypeDefault = @"default";
NSString * const kTTTIcTypeAnonymous = @"anonymous";

// Status values
NSString * const kTTTicStatusRead = @"read";
NSString * const kTTTicStatusUnread = @"unread";
NSString * const kTTTIcStatusExpired = @"expired";

// Content Type values
NSString * const kTTTicContentTypeText = @"text";
NSString * const kTTTicContentTypeImage = @"image";
NSString * const kTTTicContentTypeVoice = @"voice";


#pragma mark - PFObject Activity Class
// Class key
NSString * const kTTActivityClassKey = @"Activity";

// Field keys
NSString * const kTTActivityTypeKey = @"type";
NSString * const kTTActivityFromUserKey = @"fromUser";
NSString * const kTTActivityToUserKey = @"toUser";
NSString * const kTTActivityContentKey = @"content";
NSString * const kTTActivityTicKey = @"tic";

// Type values
NSString * const kTTActivityTypeSend = @"send";
NSString * const kTTActivityTypeFetch = @"fetch";


#pragma mark - Push Notification Payload
// intentionally kept short
// Field keys
NSString * const kTTPushNotificationPayloadTypeKey = @"t";

// Type values
NSString * const kTTPushNotificationPayloadTypeNewTic = @"nt";
NSString * const kTTPushNotificationPayloadTypeNewFriend = @"nf";


#pragma mark - Installation Class
// Field keys
NSString * const kTTInstallationUserKey = @"user";