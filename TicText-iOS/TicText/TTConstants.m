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

NSString * const kTTUIDefaultFont = @"Avenir";
NSString * const kTTUIDefaultLightFont = @"Avenir-Light";
NSString * const kTTUIDefaultUltraLightFont = @"AvenirNext-UltraLight";


#pragma mark - NSUserDefaults
NSString * const kTTUserDefaultsSessionIsValidLastCheckedKey = @"SessionIsValidLastCheckedKey";
NSString * const kTTUserDefaultsConversationsViewControllerShouldRetrieveNewTicsKey = @"UserDefaultsConversationsViewControllerShouldRetrieveNewTicsKey";


#pragma mark - NSNotification
// Log in, Sign up, Log out
NSString * const kTTLogInViewControllerDidFinishLogInNotification = @"LogInViewControllerDidFinishLogInNotification";
NSString * const kTTLogInViewControllerDidFinishSignUpNotification = @"LogInViewControllerDidFinishLogInNewUserNotification";
NSString * const kTTUserDidLogOutNotification = @"UserDidLogOut";

// Invalid session
NSString * const kTTSessionDidBecomeInvalidNotification = @"SessionDidBecomeInvalidNotification";

// User data
NSString * const kTTUserDataDidBecomeAvailableNotification = @"UserDataDidBecomeAvailableNotification";

// Push notification
NSString * const kTTApplicationDidReceiveNewTicWhileActiveNotification = @"ApplicationDidReceiveNewTicWhileActiveNotification";
NSString * const kTTApplicationDidReceiveReadTicWhileActiveNotification = @"ApplicationDidReceiveReadTicWhileActiveNotification";
NSString * const kTTApplicationDidReceiveNewUserJoinWhileActiveNotification = @"ApplicationDidReceiveNewUserJoinWhileActiveNotification";

// UserInfo keys
NSString * const kTTNotificationUserInfoErrorKey = @"error";
NSString * const kTTNotificationUserInfoTicIdKey = @"ticId";
NSString * const kTTNotificationUserInfoSenderUserIdKey = @"senderUserId";
NSString * const kTTNotificationUserInfoSendTimestampKey = @"sendTimestamp";
NSString * const kTTNotificationUserInfoTimeLimitKey = @"timeLimit";


#pragma mark - NSError
NSString * const kTTSessionErrorDomain = @"SessionError";
NSUInteger const kTTSessionErrorParseSessionFetchFailureCode = 0;
NSUInteger const kTTSessionErrorParseSessionInvalidUUIDCode = 1;


#pragma mark - Parse Local Datastore
// Pin names
NSString * const kTTLocalDatastoreFriendsPinName = @"friends";
NSString * const kTTLocalDatastoreTicsPinName = @"tics";
NSString * const kTTLocalDatastoreConversationsPinName = @"conversations";
NSString * const kTTLocalDatastorePrivateDataPinName = @"privateData";


#pragma mark - TTUser
// Field keys
NSString * const kTTUserDisplayNameKey = @"displayName";
NSString * const kTTUserProfilePictureKey = @"profilePicture";


#pragma mark - TTUserPrivateData
// Class name
NSString * const kTTUserPrivateDataClassName = @"UserPrivateData";

// Field keys
NSString * const kTTUserPrivateDataUserIdKey = @"userId";
NSString * const kTTUserPrivateDataFriendsKey = @"friends";
NSString * const kTTUserPrivateDataFacebookFriendsKey = @"facebookFriends";
NSString * const kTTUserPrivateDataActiveDeviceIdentifierKey = @"activeDeviceIdentifier";


#pragma mark - TTTic
// Class name
NSString * const kTTTicClassName = @"Tic";

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
NSString * const kTTTicRetrieveNewTicsFunction = @"retrieveNewTics";

// Type values
NSString * const kTTTicTypeDefault = @"default";
NSString * const kTTTicTypeAnonymous = @"anonymous";
NSString * const kTTTicTypeDraft = @"draft";

// Status values
NSString * const kTTTicStatusRead = @"read";
NSString * const kTTTicStatusUnread = @"unread";
NSString * const kTTTicStatusExpired = @"expired";
NSString * const kTTTicStatusDrafting = @"drafting";

// Content Type values
NSString * const kTTTicContentTypeText = @"text";
NSString * const kTTTicContentTypeImage = @"image";
NSString * const kTTTicContentTypeVoice = @"voice";


#pragma mark - TTConversation
// Class name
NSString * const kTTConversationClassName = @"Conversation";

// Field keys
NSString * const kTTConversationTypeKey = @"type";
NSString * const kTTConversationUserIdKey = @"userId";
NSString * const kTTConversationLastTicKey = @"lastTic";

// Type values
NSString * const kTTConversationTypeDefault = @"default";
NSString * const kTTConversationTypeAnonymous = @"anonymous";


#pragma mark - TTActivity
// Class name
NSString * const kTTActivityClassName = @"Activity";

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
NSString * const kTTPushNotificationPayloadTypeKey = @"type";
NSString * const kTTPushNotificationPayloadTicIdKey = @"ticId";
NSString * const kTTPushNotificationPayloadSenderUserIdKey = @"senderId";
NSString * const kTTPushNotificationPayloadSendTimestampKey = @"sendTimestamp";
NSString * const kTTPushNotificationPayloadTimeLimitKey = @"timeLimit";

// Type values
NSString * const kTTPushNotificationPayloadTypeNewTic = @"nt";
NSString * const kTTPushNotificationPayloadTypeReadTic = @"rt";
NSString * const kTTPushNotificationPayloadTypeNewFriend = @"nf";

#pragma mark - Unread Tic Attributes
NSString * const kTTUnreadTicTime = @"unreadTime";
NSString * const kTTUnreadTicColor = @"unreadColor";