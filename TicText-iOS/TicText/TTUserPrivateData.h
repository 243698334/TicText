//
//  TTUserPrivateData.h
//  TicText
//
//  Created by Kevin Yufei Chen on 3/14/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <Parse/Parse.h>

@interface TTUserPrivateData : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSArray *facebookFriends;
@property (nonatomic, strong) NSString *activeDeviceIdentifier;

@end
