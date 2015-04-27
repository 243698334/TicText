//
//  TTConstants.h
//  TicText
//
//  Created by Kevin Yufei Chen on 2/5/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - UI
extern float const kTTUIPurpleColorRed;
extern float const kTTUIPurpleColorGreen;
extern float const kTTUIPurpleColorBlue;
extern float const kTTUIPurpleColorAlpha;

#define kTTUIPurpleColor [UIColor colorWithRed:kTTUIPurpleColorRed/255.0 \
                                         green:kTTUIPurpleColorGreen/255.0 \
                                          blue:kTTUIPurpleColorBlue/255.0 \
                                         alpha:kTTUIPurpleColorAlpha/255.0]

extern NSString * const kTTUIDefaultFont;
extern NSString * const kTTUIDefaultLightFont;
extern NSString * const kTTUIDefaultUltraLightFont;


#pragma mark - NSUserDefaults
extern NSString * const kTTSessionIsValidLastCheckedKey;


#pragma mark - NSNotification
// Log in, Sign up, Log out
extern NSString * const kTTLogInViewControllerDidFinishLogInNotification;
extern NSString * const kTTLogInViewControllerDidFinishSignUpNotification;
extern NSString * const kTTUserDidLogOutNotification;

// Invalid session
extern NSString * const kTTSessionDidBecomeInvalidNotification;

// User data
extern NSString * const kTTUserDataDidBecomeAvailableNotification;

// Push notification
extern NSString * const kTTApplicationDidReceiveNewTicWhileActiveNotification;
extern NSString * const kTTApplicationDidReceiveReadTicWhileActiveNotification;
extern NSString * const kTTApplicationDidReceiveNewUserJoinWhileActiveNotification;

// UserInfo keys
extern NSString * const kTTNotificationUserInfoErrorKey;
extern NSString * const kTTNotificationUserInfoTicIdKey;
extern NSString * const kTTNotificationUserInfoSenderUserIdKey;
extern NSString * const kTTNotificationUserInfoSendTimestampKey;
extern NSString * const kTTNotificationUserInfoTimeLimitKey;


#pragma mark - NSError
extern NSString * const kTTSessionErrorDomain;
extern NSUInteger const kTTSessionErrorParseSessionFetchFailureCode;
extern NSUInteger const kTTSessionErrorParseSessionInvalidUUIDCode;


#pragma mark - Parse Local Datastore
// Pin names
extern NSString * const kTTLocalDatastoreFriendsPinName;
extern NSString * const kTTLocalDatastoreTicsPinName;
extern NSString * const kTTLocalDatastoreConversationsPinName;
extern NSString * const kTTLocalDatastorePrivateDataPinName;


#pragma mark - TTUser
// Field keys
extern NSString * const kTTUserDisplayNameKey;
extern NSString * const kTTUserProfilePictureKey;


#pragma mark - TTUserPrivateData
// Class name
extern NSString * const kTTUserPrivateDataClassName;

// Field keys
extern NSString * const kTTUserPrivateDataUserIdKey;
extern NSString * const kTTUserPrivateDataFriendsKey;
extern NSString * const kTTUserPrivateDataFacebookFriendsKey;
extern NSString * const kTTUserPrivateDataActiveDeviceIdentifierKey;


#pragma mark - TTTic
// Class name
extern NSString * const kTTTicClassName;

// Field keys
extern NSString * const kTTTicSenderKey;
extern NSString * const kTTTicTypeKey;
extern NSString * const kTTTicRecipientKey;
extern NSString * const kTTTicTimeLimitKey;
extern NSString * const kTTTicSendTimestampKey;
extern NSString * const kTTTicReceiveTimestampKey;
extern NSString * const kTTTicStatusKey;
extern NSString * const kTTTicContentTypeKey;
extern NSString * const kTTTicContentKey;

// Cloud function names
extern NSString * const kTTTicFetchTicFunction;
extern NSString * const kTTTicFetchTicFunctionTicIdParameter;
extern NSString * const kTTTicFetchTicFunctionFetchTimestampParameter;

// Type values
extern NSString * const kTTTicTypeDefault;
extern NSString * const kTTTicTypeAnonymous;
extern NSString * const kTTTicTypeDraft;

// Status values
extern NSString * const kTTTicStatusRead;
extern NSString * const kTTTicStatusUnread;
extern NSString * const kTTTicStatusExpired;
extern NSString * const kTTTicStatusDrafting;

// Content Type values
extern NSString * const kTTTicContentTypeText;
extern NSString * const kTTTicContentTypeImage;
extern NSString * const kTTTicContentTypeVoice;


#pragma mark - TTConversation
// Class name
extern NSString * const kTTConversationClassName;

// Field keys
extern NSString * const kTTConversationTypeKey;
extern NSString * const kTTConversationUserIdKey;
extern NSString * const kTTConversationLastTicKey;

// Type values
extern NSString * const kTTConversationTypeDefault;
extern NSString * const kTTConversationTypeAnonymous;


#pragma mark - TTActivity
// Class name
extern NSString * const kTTActivityClassName;

// Type values
extern NSString * const kTTActivityTypeSendTic;
extern NSString * const kTTActivityTypeReadTic;
extern NSString * const kTTActivityTypeNewUserJoin;


#pragma mark - PFInstallation
// Field key
extern NSString * const kTTInstallationUserKey;


#pragma mark - Push Notification Payload
// Field keys
extern NSString * const kTTPushNotificationPayloadTypeKey;
extern NSString * const kTTPushNotificationPayloadTicIdKey;
extern NSString * const kTTPushNotificationPayloadSenderUserIdKey;
extern NSString * const kTTPushNotificationPayloadSendTimestampKey;
extern NSString * const kTTPushNotificationPayloadTimeLimitKey;

// Type values
extern NSString * const kTTPushNotificationPayloadTypeNewTic;
extern NSString * const kTTPushNotificationPayloadTypeReadTic;
extern NSString * const kTTPushNotificationPayloadTypeNewFriend;

#pragma mark - Unread Tic Attributes
extern NSString * const kTTUnreadTicTime;
extern NSString * const kTTUnreadTicColor;

#pragma mark - Facebook
#define kTTFacebookPermissions @[@"public_profile", @"user_friends"]