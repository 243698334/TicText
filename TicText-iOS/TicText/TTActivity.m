//
//  TTActivity.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/20/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTActivity.h"

@implementation TTActivity

@dynamic type, fromUserId, toUserId, ticId;

+ (NSString *)parseClassName {
    return kTTActivityClassKey;
}

@end
