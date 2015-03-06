//
//  TTUser.h
//  TicText
//
//  Created by Terrence K on 2/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface TTUser : PFUser<PFSubclassing>

@property (nonatomic, readonly) BOOL isLinkedWithFacebook;

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSData *profilePicture;

// below are the attributes should be in the UserPrivateData table
@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSString *activeDeviceIdentifier;
@property (nonatomic, strong) NSString *facebookID;
@property (nonatomic, strong) NSArray *facebookFriends;

@end
