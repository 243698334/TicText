//
//  TTUser.m
//  TicText
//
//  Created by Terrence K on 2/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTUser.h"

#import "TTSession.h"
#import <Parse/PFObject+Subclass.h>

@implementation TTUser

@dynamic displayName, facebookId, profilePicture, profilePictureSmall, privateData;

//- (void)setProfilePictureData:(NSData *)data {
//    PFFile *file = [PFFile fileWithData:data];
//    self[kTTUserProfilePictureKey] = file;
//}
//
//- (NSData *)profilePictureData {
//    return [(PFFile *)[self objectForKey:kTTUserProfilePictureKey] getData];
//}

@end