//
//  TTTic.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/20/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTTic.h"

@implementation TTTic

@dynamic status, type, timeLimit, contentType, content, sendTimestamp, receiveTimestamp, sender, recipient;

+ (NSString *)parseClassName {
    return kTTTicClassKey;
}

@end
