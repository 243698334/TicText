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


#pragma mark - NSUserDefaults


#pragma mark - NSNotification


#pragma mark - PFUser Class
// Field keys
extern NSString * const kTTUserDisplayNameKey;
extern NSString * const kTTUserFacebookIDKey;
extern NSString * const kTTUserProfilePictureKey;
extern NSString * const kTTUserProfilePictureSmallKey;
extern NSString * const kTTUserTicTextFriendsKey;


#pragma mark - PFObject Tic Class
// Class key
extern NSString * const kTTTicClassKey;

// Field keys
extern NSString * const kTTTicSenderKey;
extern NSString * const kTTTicRecipientKey;
extern NSString * const kTTTicTimeLimitKey;
extern NSString * const kTTTicSendTimestampKey;
extern NSString * const kTTTicReceiveTimestampKey;
extern NSString * const kTTTicStatusKey;
extern NSString * const kTTTicContentKey;


#pragma mark - PFObject Activity Class
// Class key
extern NSString * const kTTActivityClassKey;

// Type values
extern NSString * const kTTActivityTypeSend;
extern NSString * const kTTActivityTypeFetch;

// Field keys
extern NSString * const kTTActivityTypeKey;
extern NSString * const kTTActivityFromUserKey;
extern NSString * const kTTActivityToUserKey;
extern NSString * const kTTActivityContentKey;
extern NSString * const kTTActivityTicKey;

