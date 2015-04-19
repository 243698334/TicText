//
//  TTUserPrivateData.m
//  TicText
//
//  Created by Kevin Yufei Chen on 3/14/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTUserPrivateData.h"

@implementation TTUserPrivateData

@dynamic userId, friends, facebookFriends, activeDeviceIdentifier;

+ (NSString *)parseClassName {
    return kTTUserPrivateDataClassName;
}

@end
