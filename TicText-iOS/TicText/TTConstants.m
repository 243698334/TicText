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

float const kTTUILightPurpleColorRed = 165.0;
float const kTTUILightPurpleColorGreen = 140.0;
float const kTTUILightPurpleColorBlue = 222.0;
float const kTTUILightPurpleColorAlpha = 255.0;

#pragma mark - NSUserDefaults
NSString * const kTTSessionIsValidLastCheckedKey = @"SessionIsValidLastCheckedKey";


#pragma mark - NSNotification
// Log in, Sign up, Log out
NSString * const kTTLogInViewControllerDidFinishLogInNotification = @"LogInViewControllerDidFinishLogInNotification";
NSString * const kTTLogInViewControllerDidFinishSignUpNotification = @"LogInViewControllerDidFinishLogInNewUserNotification";
NSString * const kTTUserDidLogOutNotification = @"UserDidLogOut";

// Invalid session
NSString * const kTTSessionDidBecomeInvalidNotification = @"SessionDidBecomeInvalidNotification";

// Push notification
NSString * const kTTApplicationDidReceiveNewTicWhileActiveNotification = @"ApplicationDidReceiveNewTicWhileActiveNotification";
NSString * const kTTApplicationDidReceiveReadTicWhileActiveNotification = @"ApplicationDidReceiveReadTicWhileActiveNotification";
NSString * const kTTApplicationDidReceiveNewUserJoinWhileActiveNotification = @"ApplicationDidReceiveNewUserJoinWhileActiveNotification";

// UserInfo keys
NSString * const kTTNotificationUserInfoErrorKey = @"error";
NSString * const kTTNotificationUserInfoTicIdKey = @"ticId";
NSString * const kTTNotificationUserInfoSenderUserIdKey = @"senderUserId";

// UI Events
NSString * const kTTScrollingImagePickerDidTapImagePickerButton = @"ScrollingImagePickerDidTapImagePickerButton";
NSString * const kTTUIImagePickerDidDismissEvent = @"kTTUIImagePickerDidDismissEvent";


#pragma mark - NSError
NSString * const kTTSessionErrorDomain = @"SessionError";
NSUInteger const kTTSessionErrorParseSessionFetchFailureCode = 0;
NSUInteger const kTTSessionErrorParseSessionInvalidUUIDCode = 1;


#pragma mark - Parse Local Datastore
// Pin names
NSString * const kTTLocalDatastoreFriendsPinName = @"friends";
NSString * const kTTLocalDatastoreTicsPinName = @"tics";


#pragma mark - TTUser
// Field keys
NSString * const kTTUserDisplayNameKey = @"displayName";
NSString * const kTTUserProfilePictureKey = @"profilePicture";


#pragma mark - TTUserPrivateData
// Class key
NSString * const kTTUserPrivateDataClassKey = @"UserPrivateData";

// Field keys
NSString * const kTTUserPrivateDataUserIdKey = @"userId";
NSString * const kTTUserPrivateDataFriendsKey = @"friends";
NSString * const kTTUserPrivateDataFacebookFriendsKey = @"facebookFriends";
NSString * const kTTUserPrivateDataActiveDeviceIdentifierKey = @"activeDeviceIdentifier";


#pragma mark - TTTic
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

// Cloud function names
NSString * const kTTTicFetchTicFunction = @"fetchTic";
NSString * const kTTTicFetchTicFunctionTicIdParameter = @"ticId";
NSString * const kTTTicFetchTicFunctionFetchTimestampParameter = @"fetchTimestamp";

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


#pragma mark - TTActivity
// Class key
NSString * const kTTActivityClassKey = @"Activity";

// Type values
NSString * const kTTActivityTypeSendTic = @"send";
NSString * const kTTActivityTypeReadTic = @"read";
NSString * const kTTActivityTypeNewUserJoin = @"join";


#pragma mark - PFInstallation
// Field key
NSString * const kTTInstallationUserKey = @"user";


#pragma mark - Push Notification Payload
// intentionally kept short
// Field keys
NSString * const kTTPushNotificationPayloadTypeKey = @"t";
NSString * const kTTPushNotificationPayloadTicIdKey = @"tid";
NSString * const kTTPushNotificationPayloadSenderUserId = @"sid";

// Type values
NSString * const kTTPushNotificationPayloadTypeNewTic = @"nt";
NSString * const kTTPushNotificationPayloadTypeReadTic = @"rt";
NSString * const kTTPushNotificationPayloadTypeNewFriend = @"nf";
