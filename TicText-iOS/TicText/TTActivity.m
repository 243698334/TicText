//
//  TTActivity.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/20/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTActivity.h"

@implementation TTActivity

@dynamic type, tic;

+ (instancetype)activityWithType:(NSString *)type {
    return [self activityWithType:type tic:nil];
}

+ (instancetype)activityWithType:(NSString *)type tic:(TTTic *)tic {
    TTActivity *activity = [self object];
    activity.type = type;
    activity.tic = tic;
    return activity;
}

+ (NSString *)parseClassName {
    return kTTActivityClassName;
}

@end
