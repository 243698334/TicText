//
//  TTUser.h
//  TicText
//
//  Created by Terrence K on 2/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTUserFacebookAuthData : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSDate *expirationDate;

@end


@class PFUser;

// A wrapper for PFUser to abstract accessing its properties.
@interface TTUser : NSObject

@property (nonatomic, strong, readonly) PFUser *pfUser;

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSData *profilePicture;
@property (nonatomic, strong) NSArray *friends;

// Initialize and wrap this instance around |user|.
- (id)initWithPFUser:(PFUser *)user;

// Get the current user.
+ (id)currentUser;

// Syntactically convenient method to quickly wrap |user|.
+ (TTUser *)wrap:(PFUser *)user;

@end
