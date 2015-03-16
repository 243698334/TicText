//
//  TTConstants.h
//  TicText
//
//  Created by Kevin Yufei Chen on 2/5/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - UIColors
extern float const kTTUIPurpleColorRed;
extern float const kTTUIPurpleColorGreen;
extern float const kTTUIPurpleColorBlue;
extern float const kTTUIPurpleColorAlpha;

#define kTTUIPurpleColor [UIColor colorWithRed:kTTUIPurpleColorRed/255.0 \
                                         green:kTTUIPurpleColorGreen/255.0 \
                                          blue:kTTUIPurpleColorBlue/255.0 \
                                         alpha:kTTUIPurpleColorAlpha/255.0]

#pragma mark - NSUserDefaults
extern NSString * const kTTParseSessionIsValidLastCheckedKey;
extern NSString * const kTTFacebookSessionIsValidLastCheckedKey;
extern NSString * const kTTReachabilityIsReachableLastCheckedKey;


#pragma mark - NSNotification
// Log in, Sign up, Log out
extern NSString * const kTTLogInViewControllerDidFinishLogInNotification;
extern NSString * const kTTLogInViewControllerDidFinishSignUpNotification;
extern NSString * const kTTUserDidLogOutNotification;

// Invalid session
extern NSString * const kTTFacebookSessionDidBecomeInvalidNotification;
extern NSString * const kTTParseSessionDidBecomeInvalidNotification;

// Push notification
extern NSString * const kTTApplicationDidReceiveNewTicWhileActiveNotification;
extern NSString * const kTTApplicationDidReceiveReadTicWhileActiveNotification;
extern NSString * const kTTApplicationDidReceiveNewUserJoinWhileActiveNotification;

// UserInfo keys
extern NSString * const kTTNotificationUserInfoErrorKey;
extern NSString * const kTTNotificationUserInfoTicIdKey;
extern NSString * const kTTNotificationUserInfoSenderUserIdKey;


#pragma mark - NSError
extern NSString * const kTTSessionErrorDomain;
extern NSUInteger const kTTSessionErrorParseSessionFetchFailureCode;
extern NSUInteger const kTTSessionErrorParseSessionInvalidUUIDCode;


#pragma mark - PFUser Class
// Field keys
extern NSString * const kTTUserDisplayNameKey;
extern NSString * const kTTUserPrivateDataKey;
extern NSString * const kTTUserFacebookIDKey;
extern NSString * const kTTUserProfilePictureKey;
extern NSString * const kTTUserProfilePictureSmallKey;
extern NSString * const kTTUserTicTextFriendsKey;
extern NSString * const kTTUserActiveDeviceIdentifier;


#pragma mark - PFObject UserPrivateData Class
// Class key
extern NSString * const kTTUserPrivateDataClassKey;


#pragma mark - PFObject Tic Class
// Class key
extern NSString * const kTTTicClassKey;

// Cloud function names
extern NSString * const kTTTicFetchTicFunction;
extern NSString * const kTTTicFetchTicFunctionTicIdParameter;
extern NSString * const kTTTicFetchTicFunctionFetchTimestampParameter;

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

// Type values
extern NSString * const kTTTicTypeDefault;
extern NSString * const kTTTIcTypeAnonymous;

// Status values
extern NSString * const kTTTicStatusRead;
extern NSString * const kTTTicStatusUnread;
extern NSString * const kTTTIcStatusExpired;

// Content Type values
extern NSString * const kTTTicContentTypeText;
extern NSString * const kTTTicContentTypeImage;
extern NSString * const kTTTicContentTypeVoice;


#pragma mark - PFObject Activity Class
// Class key
extern NSString * const kTTActivityClassKey;

// Field keys
extern NSString * const kTTActivityTypeKey;
extern NSString * const kTTActivityFromUserKey;
extern NSString * const kTTActivityToUserKey;
extern NSString * const kTTActivityContentKey;
extern NSString * const kTTActivityTicKey;

// Type values
extern NSString * const kTTActivityTypeSendTic;
extern NSString * const kTTActivityTypeReadTic;
extern NSString * const kTTActivityTypeNewUserJoin;


#pragma mark - Push Notification Payload
// Field keys
extern NSString * const kTTPushNotificationPayloadTypeKey;
extern NSString * const kTTPushNotificationPayloadTicIdKey;
extern NSString * const kTTPushNotificationPayloadSenderUserId;

// Type values
extern NSString * const kTTPushNotificationPayloadTypeNewTic;
extern NSString * const kTTPushNotificationPayloadTypeReadTic;
extern NSString * const kTTPushNotificationPayloadTypeNewFriend;


#pragma mark - Installation Class
// Field keys
extern NSString * const kTTInstallationUserKey;

#pragma mark - Miscellaneous
#define kTTFacebookPermissions @[@"public_profile", @"user_friends"]
